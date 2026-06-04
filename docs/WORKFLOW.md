# WORKFLOW.md

> Kunlik ish jarayoni, sessiya boshlash/tugatish, AI handoff, deploy.
> Oldingi: [CODE_RULES.md](CODE_RULES.md) · Keyingi: [pages/INDEX.md](pages/INDEX.md)

---

## 1. Sessiya boshlash (AI uchun)

**Har bir yangi AI sessiya** quyidagi qadamlarni bajaradi:

### 1.1 Hujjatlarni o'qish (majburiy)

```
1. docs/README.md — kompas
2. docs/ARCHITECTURE.md — folder + stack
3. docs/CODE_RULES.md — yozish qoidalari
4. docs/AUTH_AND_ROLES.md — permission matrisasi
5. docs/logs/CHANGELOG.md — oxirgi 10 yozuv
6. docs/logs/ERRORS.md — oxirgi 5 yozuv (oldingi xatolarni takrorlamaslik)
```

### 1.2 Vazifaga oid hujjat

Agar user "X sahifani qil" desa:
- `docs/pages/<X>.md` ni to'liq o'qing
- Sahifaga aloqador boshqa MD'lar (FIREBASE schema, role matrisasi) ni qayta tekshiring

Agar yangi feature desa:
- O'xshash feature MD'siga qarang
- Yangi `pages/NN_<name>.md` ni shablondan yarating ([prompts/PROMPT_TEMPLATE.md](prompts/PROMPT_TEMPLATE.md))

### 1.3 Verifikatsiya

Boshlashdan oldin (1 satr xabar bilan):
- "ARCHITECTURE.md ni o'qib chiqdim. Riverpod codegen ishlatamiz, feature-based folder."
- "Kerakli sahifa MD'sini topdim: `pages/03_map_home.md`. Boshlayman."

> Bu majburiy. User AI sessiyani "tushundimi" deb tekshirish uchun.

## 2. Sessiya tugatish (AI uchun)

Vazifa bajarilgandan keyin:

### 2.1 CHANGELOG yozish

`docs/logs/CHANGELOG.md` ga 1-3 qator qo'shing:

```markdown
## 2026-06-04 — feat(wells): well_create_edit_page yaratildi
- Yangi sahifa `lib/features/wells/presentation/well_create_edit_page.dart`
- `WellFormController` qo'shildi, validation + Firestore save
- pages/05_well_create_edit.md ni `Status: DONE` ga o'tkazdim
- Migration kerak emas
```

### 2.2 ERRORS yozish (agar bo'lsa)

Agar yo'lda 30 daqiqadan ko'p turtilgan xato yoki noma'lum-sabab xato bo'lsa, `docs/logs/ERRORS.md`:

```markdown
## 2026-06-04 — Yandex MapKit init `MissingPluginException`
**Sabab:** AndroidManifest.xml da `<meta-data android:name="ru.yandex.runtime.api.key" ...` qo'shilmagan edi.
**Yechim:** `android/app/src/main/AndroidManifest.xml` ga API key meta-data qo'shildi.
**Aloqador fayllar:** AndroidManifest.xml, AppConfig.yandexMapsApiKey
```

### 2.3 Sahifa MD'sini yangilash

Agar sahifa MD'sida `Status: WIP` yoki `TODO` bo'lsa va siz bajardingiz — `Status: DONE` ga o'tkazing.

### 2.4 Migration eslatmasi

Agar Firestore schema, Security Rules, yoki Storage rules o'zgartirdingiz:
- [FIREBASE.md](FIREBASE.md) ni yangilang.
- Deploy command'ni eslatib qoying: `firebase deploy --only firestore:rules`

## 3. AI handoff protokoli

### 3.1 Sessiya limit tugagani sezilganda

User'ga 1 qator: `Sessiya cheklov yaqin. Hozirgi vazifa X% bajarildi. Keyingi sessiya boshlanganda pages/<N>.md ni o'qisin va shu yerdan davom etsin.`

### 3.2 Sahifa MD'sini yangilash

```markdown
## Status
- WIP — 60% bajarildi (2026-06-04)
- Tugatildi: form layout + validation
- Qoldi: photo upload + Firestore save
- Keyingi sessiya: `WellFormController.uploadPhotos()` dan boshlasin
```

### 3.3 Code TODO comment

Kod ichida (faqat shu vaziyatda):
```dart
// TODO(handoff): photo upload qoldi. Bilan davom et: features/wells/application/well_form_controller.dart:42
```

> `(handoff)` prefiksi — keyingi sessiya `grep TODO(handoff)` bilan topadi.

## 4. Yangi sahifa qo'shish

### 4.1 MD avval

`docs/pages/NN_<name>.md` faylini [prompts/PROMPT_TEMPLATE.md](prompts/PROMPT_TEMPLATE.md) bo'yicha yarating.

### 4.2 INDEX yangilash

`docs/pages/INDEX.md` ga link qo'shing.

### 4.3 Route qo'shish

`lib/core/router/app_router.dart` ga `GoRoute` qo'shing.

### 4.4 Feature folder

```
lib/features/<feature>/
├── data/
├── domain/
├── application/
└── presentation/<page>.dart
```

### 4.5 Tugatgandan keyin

- `CHANGELOG.md` yozing.
- Sahifa MD'si `Status: DONE`.

## 5. Birinchi sprint (loyiha noldan boshlanganda)

Quyidagi tartibda:

1. **Flutter project yaratish**
   ```bash
   flutter create --platforms=android,windows --org=uz.turonsuv turon_suv
   cd turon_suv
   ```

2. **Folder skeletoni** ([ARCHITECTURE.md](ARCHITECTURE.md) bo'yicha) — `lib/core/`, `lib/data/`, `lib/features/auth|map|wells|pipes|masters|users|cities|settings|audit/{data,domain,application,presentation}/`.

3. **Dependencies** `pubspec.yaml`'ga ([ARCHITECTURE.md](ARCHITECTURE.md) §1).

4. **Firebase loyiha** — Console'da yaratish, `firebase_options.dart` generate (FlutterFire CLI).

5. **Yandex MapKit API key** — Console'dan olish, `.env.dev.json` ga qo'yish.

6. **Cloud Functions skeleton** (`functions/` papka, `validatePassKey` stub).

7. **Security Rules + Indexes** dasht — `firestore.rules`, `firestore.indexes.json`, `storage.rules`.

8. **Birinchi super-admin** — [AUTH_AND_ROLES.md](AUTH_AND_ROLES.md) §5 bo'yicha qo'lda yaratish.

9. **Splash → Login → Map** — birinchi 3 sahifa.
   - [pages/01_splash.md](pages/01_splash.md)
   - [pages/02_login_passkey.md](pages/02_login_passkey.md)
   - [pages/03_map_home.md](pages/03_map_home.md)

10. **Cities Management** — super-admin uchun, birinchi shahar qo'shish kerak.
    - [pages/11_cities_manage.md](pages/11_cities_manage.md)

11. **Well create/detail + Pipe create/detail** — asosiy funksionallik.
    - [pages/05_well_create_edit.md](pages/05_well_create_edit.md)
    - [pages/04_well_detail.md](pages/04_well_detail.md)
    - [pages/07_pipe_create_edit.md](pages/07_pipe_create_edit.md)
    - [pages/06_pipe_detail.md](pages/06_pipe_detail.md)

12. **Masters Management + Users Management + Settings + Profile + Audit Log**

## 6. Branching

MVP'da:
- `main` — barqaror.
- `feat/<short-name>` — feature branch.
- PR'lar yo'q (single-developer). Lekin commit'lar mantiqiy — feature per branch.

Faza 2:
- `develop` — integration.
- PR + review.

## 7. Build va run (local)

### 7.1 Dev (emulator bilan)

```bash
firebase emulators:start --import=./seed --export-on-exit
flutter run -d windows --dart-define-from-file=.env.dev.json
# yoki
flutter run -d <android-device> --dart-define-from-file=.env.dev.json
```

### 7.2 Prod build

```bash
# Android
flutter build apk --release --dart-define-from-file=.env.prod.json

# Windows
flutter build windows --release --dart-define-from-file=.env.prod.json
```

## 8. Deploy

### 8.1 Firestore rules + indexes

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

### 8.2 Cloud Functions

```bash
cd functions
npm run build
cd ..
firebase deploy --only functions
```

### 8.3 Android APK

Manual: Google Drive / Telegram orqali APK ulashish (Play Store kerak emas — ichki ilova).

### 8.4 Windows installer

`msix` package bilan `.msix` yaratish (faza 2 — hozircha `.exe` yetadi):

```bash
flutter pub run msix:create
```

## 9. Diagnostika va debug

### 9.1 Console log

`AppLogger` chiqaradigan log'lar:
```
[INFO ] auth.login_success {userId: abc123, role: admin}
[WARN ] photo.upload_retry {wellId: xxx, attempt: 2}
[ERROR] firestore.permission_denied {path: cities/x/wells}
```

### 9.2 Firestore console

[Firestore Console](https://console.firebase.google.com) → ma'lumotni tezda tekshirish.

### 9.3 Audit log

Super-admin ilova ichidan `/audit` sahifasidan ko'radi ([pages/13_audit_log.md](pages/13_audit_log.md)).

## 10. Standartdan tashqari holatlar (escalation)

| Holat | Harakat |
|---|---|
| User mavjud MD'lar bilan zid talab qildi | To'xtang, MD'larga ishora qiling, qaysi to'g'ri ekanligini so'rang. |
| Bir necha to'g'ri yo'l bor (Riverpod yoki Bloc?) | [ARCHITECTURE.md](ARCHITECTURE.md) ga qarang — agar javob bor bo'lsa, shunday qiling. Yo'q bo'lsa — 2 ta variantni qisqa ko'rsating va so'rang. |
| Firestore schema o'zgartirish kerak | Avval [FIREBASE.md](FIREBASE.md) ni yangilang, **keyin** kod yozing. |
| Permission matrisasi o'zgartirish kerak | Avval [AUTH_AND_ROLES.md](AUTH_AND_ROLES.md) jadvalini yangilang, keyin rules + repository + UI. |
| Yangi katta dep qo'shish (state lib, ORM) | Hech qachon avtomatik qo'shmang. So'rang. |

## 11. Kerak bo'lganda fayl bo'lish

Agar biron MD 500+ qator bo'lsa:
- Bo'limlarga `<topic>/` papkasiga ko'chiring.
- Asosiy MD'da link qoldiring.
- README.md "Hujjatlar xaritasi" qismini yangilang.

Misol: `FIREBASE.md` keyinroq:
- `firebase/SCHEMA.md`
- `firebase/RULES.md`
- `firebase/FUNCTIONS.md`

ga bo'linadi.

## 12. Yakuniy eslatma — vibe-coding mantra

> **Avval o'qing. Keyin yozing. Yozayotganda chiziqsiz emas. Yozib bo'lgach — yozganingni hujjatga qaytaring.**

Har sessiya: **READ → CODE → LOG**.

---

**Keyingi o'qish:** [pages/INDEX.md](pages/INDEX.md)
