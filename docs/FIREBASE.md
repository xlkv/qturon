# FIREBASE.md

> Firestore schema, Storage struktura, Security Rules, Cloud Functions.
> Oldingi: [ARCHITECTURE.md](ARCHITECTURE.md) · Keyingi: [AUTH_AND_ROLES.md](AUTH_AND_ROLES.md)

---

## 1. Loyiha (project) tuzilishi

| Muhit | Firebase project | Eslatma |
|---|---|---|
| dev | `turon-suv-dev` | Test ma'lumotlar |
| prod | `turon-suv-prod` | Real foydalanish |

Har ikkalasida quyidagi servislar:
- Firestore (Native mode)
- Storage (default bucket)
- Authentication (Custom token only — [AUTH_AND_ROLES.md](AUTH_AND_ROLES.md))
- Cloud Functions (Node.js 20, TypeScript)

## 2. Firestore schema

### Top-level collections

```
/cities/{cityId}
/users/{userId}
/logs/{logId}
/counters/_global   (kerak bo'lmasligi mumkin)
```

### `/cities/{cityId}`

```ts
{
  id: string,                  // = doc.id, denormalized
  name: string,                // "Toshkent", "Buxoro"
  center: GeoPoint,            // default map center
  defaultZoom: number,         // 11–13
  active: boolean,
  createdAt: Timestamp,
  createdBy: string,           // userId (super-admin)
}
```

### `/cities/{cityId}/masters/{masterId}`

```ts
{
  id: string,
  name: string,                // "Aziz aka", "Botir usta"
  phone: string | null,
  active: boolean,             // false → dropdown'da ko'rinmaydi (lekin eski yozuvlar saqlanadi)
  createdAt: Timestamp,
  createdBy: string,
}
```

### `/cities/{cityId}/wells/{wellId}`

```ts
{
  id: string,                  // = doc.id
  code: string,                // "B1", "B2", ... — shahar ichida unique
  location: GeoPoint,
  status: 'planned' | 'working' | 'done',
  paid: boolean,               // true default. super-admin only edits this field.
  installedAt: Timestamp | null,
  masterId: string | null,     // ref → /cities/{cityId}/masters/{masterId}
  notes: string | null,
  photoUrls: string[],         // Storage path'lar (URL emas, signed URL kerak bo'lganda olinadi)
  createdAt: Timestamp,
  createdBy: string,
  updatedAt: Timestamp,
  updatedBy: string,
}
```

### `/cities/{cityId}/pipes/{pipeId}`

```ts
{
  id: string,
  code: string,                // "P1", "P2", ... — shahar ichida unique
  points: GeoPoint[],          // minimum 2 ta nuqta (erkin polyline)
  diameterMm: number,          // mm
  lengthM: number,             // metr (user enters; polyline geo length suggest qilinadi)
  status: 'planned' | 'working' | 'done',
  paid: boolean,
  installedAt: Timestamp | null,
  masterId: string | null,
  notes: string | null,
  photoUrls: string[],
  createdAt: Timestamp,
  createdBy: string,
  updatedAt: Timestamp,
  updatedBy: string,
}
```

### `/cities/{cityId}/counters/_codes`

Auto-increment B1, B2, P1, P2 uchun (transaction bilan):

```ts
{
  well: number,   // oxirgi well code raqami (4 bo'lsa keyingi B5)
  pipe: number,   // oxirgi pipe code raqami
}
```

### `/users/{userId}`

```ts
{
  id: string,
  passKey: string,             // 6 xonali, globally unique. Hash qilinmaydi (qisqa PIN, custom token mexanizmi himoyalaydi)
  role: 'super_admin' | 'admin' | 'user',
  name: string,
  phone: string | null,
  cityIds: string[],           // super_admin: barcha cities, admin/user: bittagina
  active: boolean,
  createdAt: Timestamp,
  createdBy: string | null,    // super-admin'ni qo'lda yaratilganda null
  lastLoginAt: Timestamp | null,
}
```

> **MUHIM:** `passKey` Firestore client tomonidan **o'qib bo'lmaydi**. U faqat Cloud Function (`validatePassKey`) tomonidan o'qiladi. Security Rules da `/users/{userId}` collection client uchun yopiq. Klient userInfo'sini `/users_public/{userId}` view (Cloud Function tomonidan yangilanadi) yoki custom token claims orqali oladi.

### `/users_public/{userId}` (kerak bo'lsa)

Client xavfsiz o'qiy oladigan user info:
```ts
{
  id: string,
  name: string,
  role: string,
  cityIds: string[],
  active: boolean,
}
```
Cloud Function trigger (`onWrite /users/{userId}`) shu collectionga sync qiladi. Yoki shunchaki custom token claims'da name + role qaytariladi va alohida collection kerak emas.

### `/logs/{logId}` (audit)

```ts
{
  id: string,
  userId: string,
  userName: string,            // denormalized (log'ni o'qiyotgan vaqtda user o'chgan bo'lishi mumkin)
  role: string,
  action: 'login' | 'logout' | 'create' | 'update' | 'delete',
  entityType: 'well' | 'pipe' | 'master' | 'user' | 'city' | 'auth',
  entityId: string | null,
  cityId: string | null,
  changes: { before?: object, after?: object } | null,   // diff
  message: string | null,
  timestamp: Timestamp,
}
```

Faqat super-admin o'qiydi. Yozish — Cloud Function yoki client-side trigger orqali (har CRUD'dan keyin).

## 3. Indexes

`firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "wells",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "paid", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "wells",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "paid", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "pipes",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "paid", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "logs",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "cityId", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    }
  ]
}
```

Yangi query yozsangiz, console talab qilsa, shu yerga qo'shing va deploy.

## 4. Security Rules (Firestore)

`firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // --- Helperlar ---
    function isSignedIn() { return request.auth != null; }
    function role() { return request.auth.token.role; }
    function userId() { return request.auth.uid; }
    function userCities() { return request.auth.token.cityIds; }

    function isSuperAdmin() { return isSignedIn() && role() == 'super_admin'; }
    function isAdmin() { return isSignedIn() && role() == 'admin'; }
    function isUser() { return isSignedIn() && role() == 'user'; }

    function canSeeCity(cityId) {
      return isSuperAdmin() || cityId in userCities();
    }

    // 'paid' field — faqat super_admin yoza oladi. Admin/User uchun u doim true bo'lib qoladi.
    function paidUnchanged() {
      return !('paid' in request.resource.data.diff(resource.data).affectedKeys());
    }
    function paidIsTrueOnCreate() {
      return request.resource.data.paid == true;
    }
    function readableAsPaid(data) {
      return isSuperAdmin() || data.paid == true;
    }

    // --- /users ---
    // Client umuman o'qiy olmaydi va yoza olmaydi. Hammasi Cloud Function orqali.
    match /users/{userId} {
      allow read, write: if false;
    }

    match /users_public/{userId} {
      allow read: if isSignedIn() && (isSuperAdmin() || request.auth.uid == userId);
      allow write: if false;  // faqat Cloud Function (admin SDK)
    }

    // --- /cities ---
    match /cities/{cityId} {
      allow read: if isSignedIn() && canSeeCity(cityId);
      allow create, update, delete: if isSuperAdmin();

      match /masters/{masterId} {
        allow read: if isSignedIn() && canSeeCity(cityId);
        allow create, update, delete: if (isSuperAdmin() || isAdmin()) && canSeeCity(cityId);
      }

      match /wells/{wellId} {
        allow read: if isSignedIn() && canSeeCity(cityId) && readableAsPaid(resource.data);
        allow create: if (isSuperAdmin() || isAdmin()) && canSeeCity(cityId) && paidIsTrueOnCreate();
        allow update: if isSuperAdmin() ||
                       (isAdmin() && canSeeCity(cityId) && resource.data.paid == true && paidUnchanged());
        allow delete: if isSuperAdmin() ||
                       (isAdmin() && canSeeCity(cityId) && resource.data.paid == true);
      }

      match /pipes/{pipeId} {
        allow read: if isSignedIn() && canSeeCity(cityId) && readableAsPaid(resource.data);
        allow create: if (isSuperAdmin() || isAdmin()) && canSeeCity(cityId) && paidIsTrueOnCreate();
        allow update: if isSuperAdmin() ||
                       (isAdmin() && canSeeCity(cityId) && resource.data.paid == true && paidUnchanged());
        allow delete: if isSuperAdmin() ||
                       (isAdmin() && canSeeCity(cityId) && resource.data.paid == true);
      }

      match /counters/_codes {
        allow read: if isSignedIn() && canSeeCity(cityId);
        allow write: if (isSuperAdmin() || isAdmin()) && canSeeCity(cityId);
      }
    }

    // --- /logs ---
    match /logs/{logId} {
      allow read: if isSuperAdmin();
      allow create: if isSignedIn();   // hamma o'z action'ini yoza oladi
      allow update, delete: if false;  // log immutable
    }
  }
}
```

> **MUHIM:** Bu rules **default** — agar [AUTH_AND_ROLES.md](AUTH_AND_ROLES.md) dagi matritsa o'zgarsa, shu yerni ham yangilang.

### "User" role — yozish/o'chirish butunlay yo'q

Yuqoridagi rules'da `user` role uchun create/update/delete ruxsat yo'q (faqat read). Bu [AUTH_AND_ROLES.md](AUTH_AND_ROLES.md) ga mos.

## 5. Storage struktura

```
gs://<bucket>/
├── wells/{cityId}/{wellId}/{photoId}.jpg
├── pipes/{cityId}/{pipeId}/{photoId}.jpg
└── tmp/{userId}/{uuid}.jpg    # vaqtinchalik (yuklash paytida)
```

- Foto ko'p emas (kolodets uchun 1–5 ta odatda).
- Original + thumbnail (Cloud Function trigger `onFinalize` thumbnail yaratadi: `<photoId>_thumb.jpg`).
- Max o'lcham: 5 MB (client `flutter_image_compress` bilan compress qiladi).

### Storage rules

`storage.rules`:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    function isSignedIn() { return request.auth != null; }
    function role() { return request.auth.token.role; }
    function isSuperAdmin() { return isSignedIn() && role() == 'super_admin'; }
    function isAdmin() { return isSignedIn() && role() == 'admin'; }
    function canSeeCity(cityId) { return isSuperAdmin() || cityId in request.auth.token.cityIds; }

    match /wells/{cityId}/{wellId}/{file} {
      allow read: if isSignedIn() && canSeeCity(cityId);
      allow write: if (isSuperAdmin() || isAdmin()) && canSeeCity(cityId)
                     && request.resource.size < 5 * 1024 * 1024
                     && request.resource.contentType.matches('image/.*');
    }
    match /pipes/{cityId}/{pipeId}/{file} {
      allow read: if isSignedIn() && canSeeCity(cityId);
      allow write: if (isSuperAdmin() || isAdmin()) && canSeeCity(cityId)
                     && request.resource.size < 5 * 1024 * 1024
                     && request.resource.contentType.matches('image/.*');
    }
    match /tmp/{userId}/{file} {
      allow read, write: if isSignedIn() && request.auth.uid == userId
                          && request.resource.size < 5 * 1024 * 1024;
    }
  }
}
```

## 6. Cloud Functions

### `validatePassKey(passKey: string) → { customToken: string }`

```ts
// functions/src/auth/validate_pass_key.ts
import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';

export const validatePassKey = onCall(async (req) => {
  const passKey = String(req.data?.passKey ?? '').trim();
  if (!/^\d{6}$/.test(passKey)) throw new HttpsError('invalid-argument', 'invalid_pass_key');

  const snap = await admin.firestore()
    .collection('users').where('passKey', '==', passKey).where('active', '==', true).limit(1).get();

  if (snap.empty) throw new HttpsError('unauthenticated', 'pass_key_not_found');

  const user = snap.docs[0];
  const data = user.data();
  const claims = { role: data.role, cityIds: data.cityIds, name: data.name };
  const customToken = await admin.auth().createCustomToken(user.id, claims);

  await user.ref.update({ lastLoginAt: admin.firestore.FieldValue.serverTimestamp() });
  await admin.firestore().collection('logs').add({
    userId: user.id, userName: data.name, role: data.role,
    action: 'login', entityType: 'auth', entityId: null, cityId: null,
    changes: null, message: null,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { customToken };
});
```

### `onWellWrite`, `onPipeWrite` — audit log triggers

`onWrite` trigger har yozuvdan keyin `/logs` ga before/after diff yozadi.

### `generateThumbnail` — Storage trigger

`onFinalize` chaqirilganda thumbnail (sharp / image package) yaratadi.

### Boshqa funksiyalar (faza 2):
- `onUserCreate` — `/users_public` ga sync
- `deactivateUser` — super-admin foydalanadi
- `transferOwnership` — agar yangi super-admin kelsa eski rejimga

To'liq Functions strukturasi:
```
functions/
├── src/
│   ├── auth/
│   │   ├── validate_pass_key.ts
│   │   └── on_user_write.ts
│   ├── logs/
│   │   ├── on_well_write.ts
│   │   └── on_pipe_write.ts
│   ├── storage/
│   │   └── generate_thumbnail.ts
│   └── index.ts
├── package.json
└── tsconfig.json
```

## 7. Auto-increment kod (B1, B2 ...)

```dart
// data/repositories/well_repository.dart
Future<String> _nextCode(String cityId) async {
  final ref = _firestore.doc('cities/$cityId/counters/_codes');
  return _firestore.runTransaction((tx) async {
    final snap = await tx.get(ref);
    final current = (snap.data()?['well'] as int?) ?? 0;
    final next = current + 1;
    tx.set(ref, {'well': next}, SetOptions(merge: true));
    return 'B$next';
  });
}
```

Pipe uchun `P$next`. Transaction har doim — race condition'ga yo'l qo'ymaslik uchun.

## 8. Local dev — Firebase Emulator

`firebase.json`:
```json
{
  "emulators": {
    "auth": { "port": 9099 },
    "firestore": { "port": 8080 },
    "storage": { "port": 9199 },
    "functions": { "port": 5001 },
    "ui": { "enabled": true, "port": 4000 }
  }
}
```

Ishlatish: `firebase emulators:start --import=./seed --export-on-exit`

Test ma'lumotlar `seed/` papkada saqlanadi.

## 9. Backup va monitoring

- Firestore: kunlik avtomatik export Cloud Storage'ga (`gs://turon-suv-prod-backup/firestore/<date>/`).
- Console alertlari: Functions error rate > 1%, Firestore read > 100k/day (xarajat kuzatuvi).
- Crashlytics: Flutter side crash report.

(Bularning hammasi MVP'dan keyin — faza 2.)

## 10. Schema o'zgarishlari

Yangi field qo'shganda:
1. **Bu faylga** yangi field'ni jadvallarga qo'shing
2. Domain `freezed` model'ni yangilang (`@Default(...)` bilan migration safe qiling)
3. `fromFirestore` / `toFirestore` mapper'da hisobga oling
4. Security Rules'da `paid`-like sezgir bo'lsa qo'shing
5. [logs/CHANGELOG.md](logs/CHANGELOG.md) ga qator qo'shing

Eski yozuvlar `null` qoladi — mapper `?? default` bilan o'qiydi.

---

**Keyingi o'qish:** [AUTH_AND_ROLES.md](AUTH_AND_ROLES.md)
