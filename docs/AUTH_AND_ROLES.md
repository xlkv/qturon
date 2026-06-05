# AUTH_AND_ROLES.md

> Pass-key login, role permission matrix, super-admin yaratish.
> Oldingi: [FIREBASE.md](FIREBASE.md) · Keyingi: [CODE_RULES.md](CODE_RULES.md)

---

## 1. Login modeli — Pass-key

- Har user **6 xonali raqamli kod** ga ega (masalan `907005`).
- Kod **butun sistema bo'yicha unique** (global).
- Kod orqali kim ekanligi va roli aniqlanadi.
- Firebase Auth **custom token** mexanizmidan foydalaniladi (UI faqat kod ko'radi).
- Kod o'zgartirish faqat super-admin'da.

> Past xavfsizlik darajasi — ataylab tanlangan trade-off (UX qulayligi uchun). User'lar kam (10–30 ta), ichki ilova. Pass-key 6 xonali bo'lgani uchun brute-force ehtimoli mavjud — quyida cheklov qo'shamiz.

### 1.1 Login flow

```
[Splash]
   │
   ├── flutter_secure_storage'da pass-key bormi?
   │
   ├── HA → silent validate (Cloud Function chaqirish) → Firebase Auth custom token sign-in → /map
   │
   └── YO'Q → /login
                  │
                  ▼
              [LoginPage]
              6 xonali raqam pad
                  │
                  ▼
           validatePassKey(passKey)  (Cloud Function)
                  │
              ┌───┴───┐
              ▼       ▼
          OK ✓    Error ✗
          │           │
          ▼           ▼
   signInWithCustomToken   "Noto'g'ri kod" + cheklov
          │
          ▼
   pass-key'ni secure storage'ga saqlash (opt-in)
          │
          ▼
   /map (yoki super-admin uchun city tanlash dropdown'i)
```

### 1.2 Brute-force himoyasi

Cloud Function `validatePassKey` ichida:
- IP/installId bo'yicha rate-limit (Firestore'da `/rate_limit/{id}` doc bilan):
  - 5 ta noto'g'ri urinish → 5 daqiqa ban.
  - 20 ta noto'g'ri urinish (1 soatda) → 1 soatga ban.
- Server logiga har xato urinish yoziladi: `logs/` collectionga `action: 'login_failed'`.

```ts
// functions/src/auth/rate_limit.ts
async function checkRateLimit(installId: string): Promise<void> {
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
```

### 1.3 Logout

- Secure storage'dan pass-key'ni o'chirish
- Firebase Auth `signOut()`
- `/login` ga redirect

Logout faqat Profile sahifasida ([pages/12_profile.md](pages/12_profile.md)).

## 2. Roles

3 ta role:

| Role | UI nomi | Asosiy vazifa |
|---|---|---|
| `super_admin` | Bosh administrator | Hammasi. Pul, user, city — faqat unda. |
| `admin` | Administrator | Kunlik ish: status yangilash, master tanlash, foto qo'shish, yangi kolodets/turba qo'shish. |
| `user` | Foydalanuvchi | Faqat ko'radi. |

Role enum kod ichida: `Role.superAdmin | admin | user` ([ARCHITECTURE.md](ARCHITECTURE.md)).

## 3. Permission matrisasi

> **HAQIQAT MANBAI.** Har qanday UI/Repository/Security Rules shunga moslangan bo'lishi shart. O'zgarsa — shu jadval birinchi.

### 3.1 Kolodets va Turba

| Operatsiya | super_admin | admin | user |
|---|---|---|---|
| Xaritada `paid: true` lar ko'rinadi | ✓ | ✓ | ✓ |
| Xaritada `paid: false` lar ko'rinadi | ✓ | ✗ | ✗ |
| Detail sahifa ochish | ✓ | ✓ (faqat paid:true) | ✓ (faqat paid:true) |
| `paid` field UI'da ko'rinadi | ✓ | ✗ | ✗ |
| Yangi qo'shish | ✓ (paid'ni tanlaydi) | ✓ (avtomatik paid:true) | ✗ |
| Edit: status / master / installedAt / notes / photos | ✓ | ✓ | ✗ |
| Edit: location / points / code / diameter / length | ✓ | ✓ | ✗ |
| Edit: paid | ✓ | ✗ (UI'da yo'q va rules rad qiladi) | ✗ |
| O'chirish | ✓ | ✓ (paid:true bo'lganini) | ✗ |

### 3.2 Masters

| Operatsiya | super_admin | admin | user |
|---|---|---|---|
| Ro'yxat ko'rish | ✓ | ✓ | ✓ (read-only) |
| Yangi qo'shish | ✓ | ✓ | ✗ |
| Edit (nom/tel) | ✓ | ✓ | ✗ |
| Deactivate (active=false) | ✓ | ✓ | ✗ |
| To'liq o'chirish (hard delete) | ✓ | ✗ | ✗ |

> O'chirish o'rniga **deactivate** afzal — eski yozuvlardagi `masterId` saqlanadi.

### 3.3 Cities

| Operatsiya | super_admin | admin | user |
|---|---|---|---|
| Mavjud shaharlarni ko'rish | ✓ | ✓ (faqat o'zining) | ✓ (faqat o'zining) |
| Yangi shahar | ✓ | ✗ | ✗ |
| Edit (nom, center, zoom) | ✓ | ✗ | ✗ |
| Active/Deactivate | ✓ | ✗ | ✗ |
| O'chirish | ✓ (qiyin — barcha subcollections'ni recursively o'chirish) | ✗ | ✗ |

### 3.4 Users

| Operatsiya | super_admin | admin | user |
|---|---|---|---|
| User ro'yxati | ✓ | ✗ | ✗ |
| Yangi user | ✓ | ✗ | ✗ |
| Pass-key qayta yaratish | ✓ | ✗ | ✗ |
| Role o'zgartirish | ✓ | ✗ | ✗ |
| Deactivate | ✓ | ✗ | ✗ |
| O'z profilini ko'rish | ✓ | ✓ | ✓ |

### 3.5 Audit log

| Operatsiya | super_admin | admin | user |
|---|---|---|---|
| Log o'qish | ✓ | ✗ | ✗ |
| Yozish (avtomatik) | ✓ | ✓ | ✓ |

## 4. Implementatsiya darajasida ruxsat

3 ta darajada parallel ushlanadi:

### 4.1 Firestore Security Rules
Birinchi himoya. Hech qachon bypass qilinmaydi. [FIREBASE.md](FIREBASE.md) bo'limi 4 ga qarang.

### 4.2 Repository darajasi
Repository har query'ga role'ga qarab filter qo'shadi:

```dart
// data/repositories/well_repository.dart
Stream<List<Well>> watchAll(String cityId) {
  final query = _firestore
      .collection('cities/$cityId/wells')
      .orderBy('createdAt', descending: true);
  final user = _authProvider.read();
  if (user.role != Role.superAdmin) {
    return query.where('paid', isEqualTo: true).snapshots().map(_mapWells);
  }
  return query.snapshots().map(_mapWells);
}
```

### 4.3 UI darajasi
Permission checker har sezgir widget oldida:

```dart
// core/auth/permissions.dart
class Permissions {
  final Role role;
  const Permissions(this.role);

  bool get canSeePaidField => role == Role.superAdmin;
  bool get canEditWell => role == Role.superAdmin || role == Role.admin;
  bool get canManageUsers => role == Role.superAdmin;
  bool get canManageCities => role == Role.superAdmin;
  bool get canViewAuditLog => role == Role.superAdmin;
}
```

Riverpod orqali:
```dart
@riverpod
Permissions permissions(PermissionsRef ref) {
  final user = ref.watch(currentUserProvider).value;
  return Permissions(user?.role ?? Role.user);
}
```

UI'da:
```dart
final perms = ref.watch(permissionsProvider);
if (perms.canSeePaidField) PaidToggle(value: well.paid)
```

> **Qoida:** Hech qachon faqat UI tekshiruviga tayanmang. Server (Firestore Rules) ham, repository ham filter qo'yishi shart.

## 5. Super-admin'ni qo'lda yaratish

Birinchi super-admin Firebase Console'da qo'lda yaratiladi. Bu yagona yo'l — Cloud Function ham super-admin bo'lmagan birovga super-admin yarata olmaydi (chunki birinchisi shunday qoidaga aylantirilgan).

### Qadamlar

1. **Firebase Console** → loyihangizni oching (`turon-suv-prod`).
2. **Firestore Database** → **Start collection** (yoki mavjud `users` ni tanlang).
3. **Collection ID:** `users`.
4. **Document ID:** auto (yoki o'zingiz UUID).
5. **Fields:**

| Field | Type | Value |
|---|---|---|
| `id` | string | doc ID bilan bir xil |
| `passKey` | string | masalan `907700` (xohlagan 6 xonali raqam) |
| `role` | string | `super_admin` |
| `name` | string | "Bosh administrator" yoki ism |
| `phone` | string | null bo'lsa `null` |
| `cityIds` | array | bo'sh massiv `[]` (super_admin barcha cities'ni ko'radi) |
| `active` | boolean | `true` |
| `createdAt` | timestamp | hozir |
| `createdBy` | string | `null` (birinchi user) |
| `lastLoginAt` | timestamp | `null` |

6. **Save** bosing.
7. Ilovani oching → kiritgan `passKey`'ni kiriting → kirish bo'ladi.

> Birinchi super-admin yaratgandan keyin keyingilarini ilova ichidan (`UsersManagePage`) yarating.

### Birinchi shahar yaratish

Super-admin ilovaga kirgandan keyin **Cities Management** sahifasidan birinchi shahar qo'shadi ([pages/11_cities_manage.md](pages/11_cities_manage.md)). Shundan keyin map ko'rinadi va boshqalarni qo'shishi mumkin.

### Yo'qotilgan super-admin pass-key

Agar yagona super-admin pass-key'ini unutsa:
1. Firebase Console → Firestore → `/users/{userId}` → `passKey` field'ni yangi qiymatga edit qiling.
2. Yangi qiymat bilan kiring.

## 6. Custom token claims

`validatePassKey` Cloud Function qaytaradigan token ichida:

```json
{
  "uid": "<userId>",
  "role": "super_admin | admin | user",
  "cityIds": ["<cityId>", ...],
  "name": "<displayName>"
}
```

Bu claim'lar Firebase ID token'da ham bo'ladi → `request.auth.token.role` Security Rules'da ishlatish mumkin.

**Token amal qilish muddati:** 1 soat (Firebase default). Client SDK avtomatik refresh qiladi.

**Claim'lar yangilanishi:** Agar super-admin user'ning role'ini o'zgartirsa, eski token amal qilishini davom ettiradi (max 1 soat). Force-refresh uchun:
```dart
await FirebaseAuth.instance.currentUser?.getIdToken(true);
```
Bu `UsersManagePage` da edit qilingach chaqiriladi.

## 7. Sessiya saqlash

Pass-key `shared_preferences` da saqlanadi (default — opt-in "Eslab qol" switch login sahifasida).

- Android: SharedPreferences XML file (`/data/data/<package>/shared_prefs/`).
- Windows: `%APPDATA%\<package>\shared_preferences.json`.

> **Trade-off:** Pass-key plain text saqlanadi. Bu — 6 xonali PIN bo'lgani uchun, foydalanuvchi o'zi biladi va xohlagan vaqt o'zgartirishi mumkin. Asosiy himoya — server tomonida (Firebase custom token, rate-limit). `flutter_secure_storage` ham qarab chiqildi, lekin u Windows'da Microsoft ATL (`atlstr.h`) talab qiladi va ko'p devlarda yo'q. Ichki business app uchun bu kompromis qabul qilingan.

Storage key: `auth.passKey`.

Re-launch'da Splash uni o'qib silent login qiladi.

## 8. Sessiya tugashi

| Holat | Harakat |
|---|---|
| User active=false bo'ldi | Token 1 soat ichida amal qilishni to'xtatadi (refresh fail bo'ladi) → login'ga redirect |
| Pass-key o'zgartirildi | Eski token amal qiladi 1 soat. Force logout super-admin tomonidan (faza 2). |
| Tarmoq yo'q | Firestore offline cache ishlatadi (read-only). Yozish keyingi onlayn'da queue'lanadi (lekin biz "faqat online" tanlaganmiz — yozish bloklanadi). |

---

**Keyingi o'qish:** [CODE_RULES.md](CODE_RULES.md)
