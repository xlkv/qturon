# CHANGELOG.md

> Loyihada nima o'zgardi va qachon. Har sezilarli o'zgarishdan keyin **1-3 qator** yozing.
> Eng yangi yuqorida.

---

## Format

Har yozuv shu shakl bo'yicha:

```markdown
## YYYY-MM-DD — <type>(<scope>): <qisqa qator>
- Nima qilindi (1-3 qator)
- Qaysi fayllar
- Migration kerak bo'ldimi (rules deploy, schema)
- Aloqador MD'lar
```

`<type>`: `feat | fix | refactor | docs | chore | test | style`
`<scope>`: feature nomi yoki `docs`, `infra`, `auth`, ...

## Misol

```markdown
## 2026-06-10 — feat(wells): WellCreateEditPage yaratildi
- lib/features/wells/presentation/well_create_edit_page.dart
- WellFormController + photo upload + nextCode transaction
- Migration: yo'q
- Hujjat: pages/05_well_create_edit.md (Status: DONE)
```

---

## Yozuvlar

## 2026-06-04 — chore(windows): Windows build ishladi (flutter_map + shared_preferences)
- **Map provider:** `yandex_mapkit` → `flutter_map` + Yandex tile servers (`core-renderer-tiles.maps.yandex.net`). Pure Dart, Windows + Android + iOS hammasida ishlaydi. Yandex ko'rinishi va ma'lumotlari saqlanadi.
- **Local storage:** `flutter_secure_storage` → `shared_preferences`. Sabab: secure_storage Windows'da Microsoft ATL (`atlstr.h`) talab qiladi, ko'p devda yo'q. Trade-off documented in `AUTH_AND_ROLES.md` §7.
- `SecureStorage` interface saqlandi (impl o'zgardi) — calling code o'zgarmaydi.
- `flutter build windows --debug` → muvaffaqiyatli (`build\windows\x64\runner\Debug\turon_suv.exe`). PDB warning'lar zararsiz.
- Run test: Firebase init OK, Auth init OK, Splash → silent_login (ok: false, kutilgan), Login sahifasi ko'rinadi.
- Hujjatlar yangilandi: ARCHITECTURE.md §1 va §7, AUTH_AND_ROLES.md §7, pages/03_map_home.md.

## 2026-06-04 — feat(cities,map,profile): Profile + Cities CRUD + Map skeleton
- **Deploy:** `firebase deploy --only functions` (validatePassKey jonli, europe-west1), `firestore:rules` + `storage:rules` deployed. Compute Engine API gcloud orqali yoqildi (`gcloud services enable compute.googleapis.com`).
- **Profile (sahifa 12):** `features/auth/presentation/profile_page.dart` — avatar, ism, role badge, telefon, shaharlar, logout (confirm dialog bilan)
- **Cities CRUD (sahifa 11):** `features/cities/data/city_repository.dart`, `application/active_city_provider.dart` (SharedPreferences orqali super-admin tanlovini eslab qoladi), `presentation/cities_manage_page.dart`, `widgets/city_form_sheet.dart`. Router guard (faqat super_admin).
- **Map skelet (sahifa 03 — WIP):** `features/map/presentation/map_home_page.dart` — AppBar (super-admin uchun shahar dropdown), Drawer (Map/Ustalar/Shaharlar/Foydalanuvchilar/Audit log/Profil — perms bilan). YandexMap Android'da render. Windows desktopda "qo'llab-quvvatlanmaydi" empty state. Empty state'lar: shahar yo'q (Shahar qo'shish tugmasi), shahar tayinlanmagan.
- **Router:** `/profile`, `/cities`, `/map` real sahifalarga ulandi. Placeholder o'chirildi.
- `firestore.rules`: ishlatilmaydigan `isUser` helper o'chirildi.
- `flutter analyze` toza, widget_test o'tdi.
- Migration: Keyingi qadam — birinchi super-admin Firebase Console'da qo'lda yaratish (AUTH_AND_ROLES.md §5), keyin login real ishlaydi.

## 2026-06-04 — feat(auth): Splash + Login (pass-key) + auth-gated router
- `flutterfire configure --project=agrobankcallcentertrain` — `lib/firebase_options.dart` (gitignored)
- Domain modellari: `AppUser`, `Role`, `ObjectStatus`, `City`, `Master`, `Well`, `Pipe` (Freezed 3.x — `abstract class with _$X`)
- `core/auth/permissions.dart` + `permissionsProvider` — role asoslangan UI ruxsatlari
- `core/utils/secure_storage.dart` — `flutter_secure_storage` wrapper
- `core/logging/app_logger.dart` + `core/errors/app_exception.dart` (sealed hierarchy)
- `features/auth/data/auth_repository.dart` — `validatePassKey` Cloud Function chaqirig'i + custom token sign-in
- `features/auth/application/{current_user_provider, splash_controller, login_controller}`
- `features/auth/presentation/splash_page.dart` (logo + silent login)
- `features/auth/presentation/login_page.dart` + `PinInput` + `NumericKeypad` (fizik klaviatura ham qabul qiladi)
- `core/router/app_router.dart` — Firebase Auth state'ga asoslangan redirect (`/splash` → `/login` yoki `/map`)
- `main.dart` — `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
- Codegen: `dart run build_runner build` — 5 ta Freezed fayl. `dependency_overrides: analyzer_plugin: ^0.13.4` (analyzer 7.x bilan moslash uchun)
- `flutter analyze` toza, `flutter test` o'tdi
- Migration: Cloud Functions (`validatePassKey`) hali deploy qilinmagan — login serverda fail bo'ladi. Keyingi qadam: birinchi super-admin Firebase Console'da qo'lda yaratish + functions deploy.

## 2026-06-04 — chore(infra): Flutter project + Firebase config skeleton
- `flutter create . --platforms=android,windows --org=uz.turonsuv --project-name=turon_suv`
- `pubspec.yaml`: Riverpod codegen, Freezed, go_router, Firebase suite, yandex_mapkit, image_picker, secure_storage, shared_preferences
- `analysis_options.yaml`: CODE_RULES.md §15 lint qoidalari
- `lib/` skelet: core/{config,theme,router}, features/{auth,map,wells,pipes,masters,users,cities,settings,audit}/*
- `lib/main.dart` + `lib/app.dart` — ProviderScope + MaterialApp.router stub
- `lib/core/router/app_router.dart` — Splash/Login/Map placeholder route'lar
- `lib/core/theme/{app_spacing,app_colors,app_theme}.dart`
- `firebase.json`, `.firebaserc`, `firestore.rules`, `firestore.indexes.json`, `storage.rules`
- `functions/`: TypeScript skeleton + `validatePassKey` Cloud Function stub
- `flutter analyze` — toza
- Migration: hech narsa hali deploy qilinmagan. Firebase loyihasi yaratilishi kutilmoqda.

## 2026-06-04 — docs(init): loyiha hujjatlari skeletoni yaratildi
- docs/README.md — kirish nuqtasi
- docs/ARCHITECTURE.md, FIREBASE.md, AUTH_AND_ROLES.md, CODE_RULES.md, WORKFLOW.md
- docs/pages/INDEX.md + 13 ta sahifa MD (01-13)
- docs/prompts/PROMPT_TEMPLATE.md
- docs/logs/CHANGELOG.md + ERRORS.md (skelet)
- Status: PLANLASH BOSQICHI.
