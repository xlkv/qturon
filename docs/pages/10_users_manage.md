# 10_users_manage.md — Foydalanuvchilar (super_admin)

> Marshrut: `/users` · Role: super_admin · Status: TODO
> Index: [INDEX.md](INDEX.md)

---

## 1. Maqsad

Super-admin foydalanuvchilarni boshqaradi: yaratish, role berish, shahar tayinlash, deactivate, pass-key qayta yaratish.

## 2. UI

### AppBar
- Sarlavha: `Foydalanuvchilar`
- Trailing: **Yangi** (+) tugma

### Body
- `ListView` — har bir user:
  - leading: avatar
  - title: ism
  - subtitle: role badge + shahar(lar) nomi
  - trailing: status (active/inactive) + 3 nuqta menyu
- Search bar (ism yoki pass-key bo'yicha).
- Filter: role / city / active.

### Yangi/Edit dialog (BottomSheet)
- **Ism** (required)
- **Telefon** (ixtiyoriy)
- **Role** — Radio (super_admin / admin / user)
- **Shahar(lar)** — multi-select chip'lar (super_admin uchun "Hammasi" → cityIds bo'sh)
- **Pass-key** — auto-generated 6 xonali (Refresh tugma bilan qayta yaratish), copy tugma
- **Active** — switch (edit'da)
- "Saqlash" / "Bekor qil"

> Pass-key — server tomondan unique tekshiriladi. Agar dublikat bo'lsa — yangi tasodifiy yaratiladi.

## 3. State

```dart
@riverpod
Stream<List<User>> usersStream(UsersStreamRef ref);

@riverpod
class UserFormController extends _$UserFormController {
  @override
  UserFormState build(String? userId);
  void updateRole(Role r);
  void updateCityIds(List<String> ids);
  void generateNewPassKey();
  Future<void> submit();
}
```

`UserRepository` — Cloud Function orqali (chunki `/users` collection client'dan o'qib bo'lmaydi):
- `listUsers()` — Cloud Function `listUsers` qaytaradi (admin SDK).
- `saveUser(...)` — Cloud Function `saveUser`.
- `regeneratePassKey(userId)` — Cloud Function.
- `deactivateUser(userId)` — Cloud Function.

Yoki: `/users_public` ni read uchun (lekin pass-key u yerda yo'q). Pass-key faqat bir marta yaratilganda yoki regenerate qilinganda super-admin'ga ko'rsatiladi va keyin yashiriladi.

> **MUHIM:** pass-key plain text saqlanadi (Firestore'da). Lekin client unga `/users` orqali yetib bormaydi. Faqat Cloud Function ma'mur SDK orqali yetadi. Super-admin formada yangi yoki regenerate'dan keyin pass-key'ni ekranda ko'radi, copy qiladi va keyin u qayta ko'rinmaydi (faqat regenerate kerak bo'lganda).

## 4. Cloud Functions (qo'shimcha)

```ts
export const listUsers = onCall(async (req) => {
  requireSuperAdmin(req);
  const snap = await db.collection('users').get();
  return snap.docs.map(d => ({...d.data(), passKey: undefined}));  // passKey yashir
});

export const createUser = onCall(async (req) => {
  requireSuperAdmin(req);
  const { name, phone, role, cityIds } = req.data;
  // generate unique 6-digit passKey
  let passKey = randomPassKey();
  while (await passKeyExists(passKey)) passKey = randomPassKey();
  // Create Firebase Auth user
  const auth = await admin.auth().createUser({ displayName: name });
  await db.collection('users').doc(auth.uid).set({
    id: auth.uid, passKey, role, name, phone: phone ?? null, cityIds,
    active: true, createdAt: serverTimestamp(), createdBy: req.auth!.uid,
    lastLoginAt: null,
  });
  return { userId: auth.uid, passKey };  // pass-key bir marta qaytaradi
});

export const updateUser = onCall(async (req) => {
  requireSuperAdmin(req);
  // role, cityIds, name, phone, active update
});

export const regeneratePassKey = onCall(async (req) => {
  requireSuperAdmin(req);
  const newKey = await uniquePassKey();
  await db.doc(`users/${req.data.userId}`).update({ passKey: newKey });
  return { passKey: newKey };
});

export const deactivateUser = onCall(async (req) => {
  requireSuperAdmin(req);
  await db.doc(`users/${req.data.userId}`).update({ active: false });
  await admin.auth().updateUser(req.data.userId, { disabled: true });
});
```

## 5. Permission

Faqat super_admin. Router guard: boshqa role → `/map`.

## 6. Edge case

| Holat | Harakat |
|---|---|
| Birinchi run, user mavjud emas | Faqat super_admin'ning o'zi ko'rinadi |
| Bir o'zini deactivate qilmoqchi | Tasdiqlash "Siz o'z hisobingizni o'chiryapsiz. Ishonchingiz komilmi?" — agar yagona super-admin'i ekanlar — ruxsat berma |
| Pass-key generate 100 marta dublikat | Cloud Function 7 xonaga oshiradi (juda nadir) |

## 7. Aloqador

- [../AUTH_AND_ROLES.md §5](../AUTH_AND_ROLES.md) — birinchi super-admin
- [../FIREBASE.md §6](../FIREBASE.md) — Cloud Functions

## 8. Build prompt

```
docs/README.md, docs/pages/10_users_manage.md, docs/AUTH_AND_ROLES.md ni o'qing.

Vazifa: UsersManagePage + Cloud Functions (createUser, listUsers, updateUser, regeneratePassKey, deactivateUser).

Joylashuv (Flutter):
- lib/features/users/presentation/users_manage_page.dart
- lib/features/users/presentation/widgets/user_form_sheet.dart
- lib/features/users/presentation/widgets/passkey_display.dart (copy tugmasi bilan)
- lib/features/users/application/users_provider.dart
- lib/features/users/application/user_form_controller.dart
- lib/features/users/data/user_repository.dart (Cloud Function client)
- lib/features/users/domain/app_user.dart (User nomi konflikt — AppUser)

Joylashuv (Functions):
- functions/src/users/list_users.ts
- functions/src/users/create_user.ts
- functions/src/users/update_user.ts
- functions/src/users/regenerate_pass_key.ts
- functions/src/users/deactivate_user.ts
- functions/src/users/helpers.ts (requireSuperAdmin, uniquePassKey)

Talab:
1. Router guard.
2. Bottom sheet form yangi va edit uchun.
3. Pass-key generate Refresh tugma — Cloud Function chaqirig'i.
4. Pass-key yaratilgandan keyin "Foydalanuvchiga uzating" warning + copy tugma.
5. Edit'da pass-key ko'rsatilmaydi (faqat "Qayta yaratish" tugma).
6. role ga qarab "Shaharlar" multi-select yoki "Hammasi" radio.

Code rules: Riverpod, freezed, AppSpacing, Logger.

Tugatgach: Status DONE + INDEX + CHANGELOG.
```

## Status

TODO
