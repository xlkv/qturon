# 12_profile.md — Profil sahifa

> Marshrut: `/profile` · Role: hammada · Status: TODO
> Index: [INDEX.md](INDEX.md)

---

## 1. Maqsad

Hozirgi foydalanuvchi ma'lumotlari + tizimdan chiqish.

## 2. UI

- Avatar (ism birinchi harfi, rangli fon).
- Ism (katta shrift).
- Role badge.
- Telefon (agar bor).
- Shahar(lar) ro'yxati.
- Oxirgi kirish vaqti.
- Pastda: **Tizimdan chiqish** (qizil tugma).

### Edit imkoniyati
- MVP: yo'q. Faqat super-admin boshqalarning ma'lumotini Users page'da o'zgartiradi.
- O'z ismini o'zgartirish — faza 2.

## 3. State

```dart
@riverpod
User? currentUser(CurrentUserRef ref) {
  final auth = FirebaseAuth.instance.currentUser;
  if (auth == null) return null;
  // /users_public/{uid} yoki custom token claims'dan o'qish
  return User(
    id: auth.uid,
    name: (auth.idToken?.claims['name'] as String?) ?? '',
    role: Role.byName((auth.idToken?.claims['role'] as String?) ?? 'user'),
    cityIds: List<String>.from(auth.idToken?.claims['cityIds'] ?? const []),
    // ...
  );
}
```

Yoki `/users_public/{uid}` stream — agar ism o'zgarganda real-time yangilanish kerak bo'lsa.

## 4. Logika

- Logout: confirm dialog → `SecureStorage.delete('auth.passKey')` → `FirebaseAuth.signOut()` → `router.go('/login', extra: 'logged_out')`.

## 5. Permission

Hammaga o'z profilini ko'rish.

## 6. Aloqador

- [08_settings.md](08_settings.md) — logout tugma o'sha yerda ham bor (duplikat OK)
- [../AUTH_AND_ROLES.md §7](../AUTH_AND_ROLES.md) — sessiya saqlash

## 7. Build prompt

```
docs/README.md, docs/pages/12_profile.md, docs/AUTH_AND_ROLES.md ni o'qing.

Vazifa: ProfilePage + currentUserProvider.

Joylashuv:
- lib/features/auth/presentation/profile_page.dart
- lib/features/auth/application/current_user_provider.dart
- lib/features/auth/domain/user.dart (freezed)
- lib/features/auth/domain/role.dart (enum)

Talab:
1. currentUserProvider — FirebaseAuth claims'dan o'qish (yoki users_public stream).
2. UI: avatar, ism, role, telefon, shaharlar, lastLoginAt.
3. Logout: ConfirmDialog → storage clear → signOut → /login.

Code rules: standart.

Tugatgach: Status DONE + INDEX + CHANGELOG.
```

## Status

TODO
