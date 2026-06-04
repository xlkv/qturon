# Turon Suv

Toza suv yetkazib berish kompaniyasi uchun kolodets/turba boshqaruv ilovasi.
Flutter (Android + Windows) + Firebase + Yandex Maps.

> **Hujjat:** [docs/README.md](docs/README.md) — loyiha haqida hamma narsa shu yerda.
> Yangi AI sessiya boshlanganda **birinchi shuni o'qing**.

## Tezkor boshlash

```bash
# 1. Dependencies
flutter pub get

# 2. Codegen (Riverpod + Freezed)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. .env.dev.json yaratish (.env.dev.example.json dan)
#    → Yandex Maps API key qo'shing
#    → Firebase project ID

# 4. Firebase setup (alohida)
flutterfire configure   # lib/firebase_options.dart generate
firebase deploy --only firestore:rules,firestore:indexes,storage   # security rules

# 5. Run
flutter run -d windows --dart-define-from-file=.env.dev.json
# yoki
flutter run -d <android-device> --dart-define-from-file=.env.dev.json
```

## Birinchi super-admin yaratish

[docs/AUTH_AND_ROLES.md §5](docs/AUTH_AND_ROLES.md) bo'yicha Firebase Console'da qo'lda.

## Loyiha tuzilishi

- [`lib/`](lib/) — Flutter ilova kodi (feature-based)
- [`functions/`](functions/) — Firebase Cloud Functions (TypeScript)
- [`docs/`](docs/) — barcha hujjatlar (har sahifa va qoidalar)
- `firestore.rules`, `firestore.indexes.json`, `storage.rules` — Firebase config
- `firebase.json`, `.firebaserc` — Firebase CLI config

## Litsenziya

Xususiy loyiha.
