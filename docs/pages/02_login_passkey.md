# 02_login_passkey.md — Pass-key kirish sahifasi

> Marshrut: `/login` · Role: hammada · Status: TODO
> Index: [INDEX.md](INDEX.md)

---

## 1. Maqsad

Foydalanuvchi 6 xonali kirish kodini kiritadi va tizimga kiradi.

## 2. UI

- Yuqorida: logo (kichik).
- Sarlavha: "Tizimga kiring"
- Qatorli ko'rsatkich: 6 ta bo'sh katak (PIN-pad style).
- Pastda: 0-9 raqamli numeric keypad (3x4 grid + backspace).
- 6-raqamlik to'liq kiritilsa → avtomatik validate boshlanadi (button bosish kerak emas).
- Loading paytida keypad disable.
- Xato bo'lsa: shake animatsiya + qizil xabar (`"Noto'g'ri kod. Qaytadan urinib ko'ring."`).
- Pastda kichik switch: "Eslab qol" (default ON).

> Numeric keypad — chunki Windows'da tap qulay, klaviatura ham ishlaydi. Pad o'zi `RawKeyboardListener` bilan klaviatura raqamini ham qabul qiladi.

## 3. State

`loginControllerProvider` — `AsyncNotifier<void>`:
```dart
class LoginState {
  final String input;          // hozirgacha kiritilgan raqamlar
  final bool isLoading;
  final String? error;
  final bool rememberMe;
}
```

Metodlar:
- `appendDigit(String d)` — `input.length < 6` bo'lsa qo'shadi. 6 ta bo'lganda auto-submit.
- `backspace()`
- `clear()`
- `setRememberMe(bool)`
- `submit()` — Cloud Function chaqiradi, custom token bilan sign-in qiladi, optional storage'ga saqlaydi, `/map` ga.

## 4. Logika

```
submit():
  1. validate input — 6 ta raqam
  2. call CloudFunction.validatePassKey(input)
  3. await FirebaseAuth.signInWithCustomToken(token)
  4. if (rememberMe) SecureStorage.write('auth.passKey', input)
  5. router.go('/map')

Rate-limit (Cloud Function tomonidan):
  - 5 ta xato → 5 daqiqa ban → UI'da timer ko'rsatish: "Qayta urinishlar tugadi. 5 daqiqadan keyin urinib ko'ring."
```

## 5. Firestore

- O'qish: yo'q.
- Yozish: `validatePassKey` Cloud Function ichida — `users.lastLoginAt` va `logs/` audit.

## 6. Permission

Hammaga (login'gacha role yo'q).

## 7. Edge case

| Holat | Harakat |
|---|---|
| Internet yo'q | Toast "Internet bilan ulanish kerak" |
| Kod noto'g'ri | Shake + xabar, input tozalash |
| Cloud Function timeout | "Server javob bermayapti, qayta urinib ko'ring" |
| Rate-limit (resource-exhausted) | Timer + button disable |
| Token sign-in xato | Storage tozalash + qayta input |

## 8. Navigation

- Muvaffaqiyatli login → `/map` (`pushReplacement`).
- Logout dan kelgan bo'lsa, `extra` parametri orqali "Tizimdan chiqildi" snackbar.

## 9. Keyboard handling

```dart
RawKeyboardListener(
  autofocus: true,
  onKey: (event) {
    if (event is RawKeyDownEvent) {
      final ch = event.character;
      if (ch != null && RegExp(r'\d').hasMatch(ch)) ref.read(...).appendDigit(ch);
      if (event.logicalKey == LogicalKeyboardKey.backspace) ref.read(...).backspace();
    }
  },
  child: ...
)
```

## 10. Aloqador hujjatlar

- [../AUTH_AND_ROLES.md](../AUTH_AND_ROLES.md) — login flow + rate-limit
- [../FIREBASE.md §6](../FIREBASE.md) — `validatePassKey`

## 11. Build prompt

```
docs/README.md, docs/AUTH_AND_ROLES.md (1-bo'limgacha), docs/pages/02_login_passkey.md ni o'qing.

Vazifa: LoginPage + loginControllerProvider yaratish.

Joylashuv:
- lib/features/auth/presentation/login_page.dart
- lib/features/auth/presentation/widgets/pin_input.dart (6 ta katak)
- lib/features/auth/presentation/widgets/numeric_keypad.dart (3x4 + backspace)
- lib/features/auth/application/login_controller.dart

Talab:
1. PinInput — 6 ta katak. Joriy index'ga underline border. To'lganini bold.
2. NumericKeypad — 0-9 (1-9 + 0 markazda), backspace, clear (long-press 0?).
3. RawKeyboardListener — fizik klaviatura raqamlarini qabul qilsin.
4. 6 ta raqam to'lganda auto-submit (button kerak emas).
5. Loading: keypad disable + spinner.
6. Xato: shake animatsiya + qizil error text + input tozalash.
7. "Eslab qol" switch default ON.
8. Cloud Function chaqirig'i mock'siz to'g'ridan-to'g'ri (functions:validatePassKey via FirebaseFunctions instance).
9. Muvaffaqiyat: signInWithCustomToken → SecureStorage.write (rememberMe bo'lsa) → router.go('/map').

Code rules: Riverpod codegen, freezed for LoginState, no print, prefer_const.

Tugatgach:
- pages/02_login_passkey.md → Status: DONE
- pages/INDEX.md jadvalini yangilang
- logs/CHANGELOG.md ga 1 qator
```

## Status

TODO
