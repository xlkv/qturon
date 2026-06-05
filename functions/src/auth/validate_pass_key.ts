import * as admin from 'firebase-admin';
import { onCall, HttpsError, CallableRequest } from 'firebase-functions/v2/https';

interface ValidatePassKeyData {
  passKey?: string;
  installId?: string;
}

interface ValidatePassKeyResult {
  customToken: string;
}

export const validatePassKey = onCall<ValidatePassKeyData, Promise<ValidatePassKeyResult>>(
  { region: 'europe-west1' },
  async (req: CallableRequest<ValidatePassKeyData>) => {
    const passKey = String(req.data?.passKey ?? '').trim();
    const installId = String(req.data?.installId ?? 'unknown');

    if (!/^\d{6}$/.test(passKey)) {
      throw new HttpsError('invalid-argument', 'invalid_pass_key');
    }

    await checkRateLimit(installId);

    const db = admin.firestore();
    const snap = await db
      .collection('users')
      .where('passKey', '==', passKey)
      .where('active', '==', true)
      .limit(1)
      .get();

    if (snap.empty) {
      await logFailedAttempt(installId, passKey);
      throw new HttpsError('unauthenticated', 'pass_key_not_found');
    }

    const userDoc = snap.docs[0];
    const data = userDoc.data();

    const rawCityIds: unknown[] = Array.isArray(data.cityIds) ? data.cityIds : [];
    const cityIds = rawCityIds.filter(
      (v): v is string => typeof v === 'string' && v.length > 0
    );
    const claims = {
      role: data.role,
      cityIds,
      name: data.name ?? '',
    };

    // Firebase Auth user mavjudligini ta'minlaymiz (setCustomUserClaims uchun zarur).
    // Windows C++ SDK custom token ichidagi claims'ni ID token'ga o'tkazmaydi —
    // shuning uchun claims'ni user account'ga yozamiz.
    try {
      await admin.auth().getUser(userDoc.id);
    } catch (_) {
      await admin.auth().createUser({
        uid: userDoc.id,
        displayName: data.name ?? undefined,
      });
    }
    await admin.auth().setCustomUserClaims(userDoc.id, claims);

    const customToken = await admin.auth().createCustomToken(userDoc.id);

    await userDoc.ref.update({
      lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await db.collection('logs').add({
      userId: userDoc.id,
      userName: data.name ?? '',
      role: data.role,
      action: 'login',
      entityType: 'auth',
      entityId: null,
      cityId: null,
      changes: null,
      message: null,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { customToken };
  }
);

async function checkRateLimit(installId: string): Promise<void> {
  const db = admin.firestore();
  const ref = db.doc(`rate_limit/${installId}`);
  const now = Date.now();
  const snap = await ref.get();
  const data = snap.data() ?? { count: 0, windowStart: now };

  if (now - data.windowStart > 60 * 60 * 1000) {
    data.count = 0;
    data.windowStart = now;
  }

  if (data.count >= 20) {
    throw new HttpsError('resource-exhausted', 'too_many_attempts_try_later');
  }

  data.count += 1;
  await ref.set(data);
}

async function logFailedAttempt(installId: string, _passKey: string): Promise<void> {
  const db = admin.firestore();
  await db.collection('logs').add({
    userId: null,
    userName: null,
    role: null,
    action: 'login_failed',
    entityType: 'auth',
    entityId: null,
    cityId: null,
    changes: null,
    message: `installId=${installId}`,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
}
