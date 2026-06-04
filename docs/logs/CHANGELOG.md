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
