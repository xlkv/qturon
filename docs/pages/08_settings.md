# 08_settings.md — Sozlamalar

> Marshrut: `/settings` · Role: hammada · Status: TODO
> Index: [INDEX.md](INDEX.md)

---

## 1. Maqsad

Ilova sozlamalari. MVP'da minimal.

## 2. UI

`ListView` bilan `ListTile` lar:

### Ko'rinish
- **Tema**: Light / Dark / System (RadioListTile) — `ThemeMode` controllerga yoziladi.

### Hisob
- **Profil** → `/profile`
- **Tizimdan chiqish** — qizil, confirm dialog bilan

### Boshqarish (faqat super_admin)
- **Foydalanuvchilar** → `/users`
- **Shaharlar** → `/cities`
- **Audit log** → `/audit`

### Boshqaruv (super_admin, admin)
- **Ustalar** → `/masters`

### Ilova haqida
- Versiya (package_info_plus): `1.0.0+1`
- Build raqami
- Loyiha repo havolasi (agar bor bo'lsa)

## 3. State

```dart
@riverpod
class ThemeMode extends _$ThemeMode {
  @override
  ThemeMode build() {
    final saved = SharedPreferences.getString('theme_mode');
    return ThemeMode.values.byNameOrNull(saved ?? '') ?? ThemeMode.system;
  }
  Future<void> set(ThemeMode mode) async {
    state = mode;
    await SharedPreferences.setString('theme_mode', mode.name);
  }
}
```

`MaterialApp.router` `themeMode: ref.watch(themeModeProvider)` watch qiladi.

## 4. Logikasi

- Logout: confirm → `SecureStorage.delete('auth.passKey')` + `FirebaseAuth.signOut()` + `router.go('/login', extra: 'logged_out')`.

## 5. Permission

Sahifa hammaga. ListTile'lar perms'ga qarab ko'rsatiladi (`ref.watch(permissionsProvider)`).

## 6. Edge case

- Versiya o'qish xato → "Noma'lum versiya".

## 7. Aloqador

- [12_profile.md](12_profile.md)
- [09_masters_manage.md](09_masters_manage.md), [10_users_manage.md](10_users_manage.md), [11_cities_manage.md](11_cities_manage.md), [13_audit_log.md](13_audit_log.md)

## 8. Build prompt

```
docs/README.md, docs/pages/08_settings.md ni o'qing.

Vazifa: SettingsPage + ThemeModeProvider.

Joylashuv:
- lib/features/settings/presentation/settings_page.dart
- lib/features/settings/application/theme_mode_provider.dart
- lib/core/utils/shared_prefs.dart (wrapper, lazy init)

Talab:
1. ListView + ListTile dizayni.
2. Tema RadioListTile — system / light / dark.
3. Logout: Dialog → Storage clear → signOut → /login.
4. Boshqaruv linklari permissions'ga qarab ko'rsatish.
5. Versiya: package_info_plus orqali.

Code rules: standart.

Tugatgach: Status DONE + INDEX + CHANGELOG.
```

## Status

TODO
