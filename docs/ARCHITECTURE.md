# ARCHITECTURE.md

> Loyiha qanday qurilgan: papka, qatlamlar, state, navigation, packages.
> Kirish: [README.md](README.md) · Keyingi: [FIREBASE.md](FIREBASE.md) · [CODE_RULES.md](CODE_RULES.md)

---

## 1. Texnik stack

| Soha | Tanlov | Sabab |
|---|---|---|
| Framework | Flutter (stable, 3.x+) | Cross-platform, Android+Windows |
| Til | Dart 3.x (sound null safety, records) | Default |
| State | `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator` | Codegen + compile-time safety |
| Router | `go_router` | Declarative, deep-linking-ready |
| Map | `flutter_map` + Yandex tile servers + `latlong2` | Pure Dart, Windows + Android + iOS + Web ishlaydi. Yandex'ning ko'cha/uy ma'lumotlari `core-renderer-tiles.maps.yandex.net` orqali. Tile URL'lar ToS bo'yicha kulrang zona — kichik ichki ilova uchun OK |
| Backend | Firebase: `firebase_core`, `cloud_firestore`, `firebase_storage`, `firebase_auth` (custom token) | Hosted, real-time, offline cache |
| Cloud Functions | `firebase_functions` (Node.js 20 TypeScript) | Pass-key → custom token validatsiyasi |
| Image | `image_picker`, `cached_network_image`, `flutter_image_compress` | Foto yuklash + cache |
| Local storage | `shared_preferences` | Pass-key cache + active city. `flutter_secure_storage` ishlatilmaydi — Windows'da C++ ATL talab qiladi. Pass-key himoyasi Firebase custom token tomonida. |
| Log | `logger` package + custom wrapper | Console + Firestore'ga `logs/` |
| Form | Built-in `Form` + `TextFormField` + custom validators | Riverpod controllers bilan |
| Lint | `flutter_lints` + custom `analysis_options.yaml` | [CODE_RULES.md](CODE_RULES.md) ga qarang |
| Codegen | `build_runner` (Riverpod, Freezed, JsonSerializable) | One-time build, faster dev |
| Modellar | `freezed` + `json_serializable` | Immutable + Firestore serialize |
| Test | `flutter_test` + `mocktail` | Unit + widget |
| ID generation | `uuid` package (v4) | Client-side ID, lekin Firestore'da `code` (B1, B2) bizning audit qiymatimiz |

> Yangi package qo'shishdan oldin **shu jadvalga qarang** va dublikat yo'qligini tekshiring.

## 2. Folder strukturasi

```
lib/
├── main.dart                       # Firebase init, runApp(ProviderScope)
├── app.dart                        # MaterialApp.router + theme + locale
├── core/
│   ├── theme/                      # AppTheme (light + dark), AppColors, AppTextStyles
│   ├── router/                     # go_router config, route names, redirect logic
│   ├── constants/                  # App-wide constants (status enums, default zoom)
│   ├── utils/                      # Date format, distance calc, validators
│   ├── widgets/                    # Reusable: AppButton, AppTextField, LoadingView, ErrorView
│   ├── extensions/                 # BuildContext, GeoPoint, DateTime extensions
│   ├── errors/                     # AppException, ErrorMapper
│   └── logging/                    # AppLogger wrapper (console + Firestore)
├── data/
│   ├── firebase/                   # Firebase initialization, FirebaseProviders
│   └── shared/                     # Cross-feature data (e.g. CityRepository)
└── features/
    ├── auth/
    │   ├── data/                   # AuthRepository (Cloud Function call, secure storage)
    │   ├── domain/                 # User entity, Role enum, AuthState
    │   ├── application/            # authControllerProvider, currentUserProvider
    │   └── presentation/           # SplashPage, LoginPage, ProfilePage
    ├── map/
    │   ├── application/            # mapControllerProvider, markersProvider
    │   └── presentation/           # MapHomePage, WellMarker, PipePolyline widgets
    ├── wells/
    │   ├── data/                   # WellRepository
    │   ├── domain/                 # Well entity, WellStatus enum
    │   ├── application/            # wellsStreamProvider(cityId), wellFormController
    │   └── presentation/           # WellDetailPage, WellCreateEditPage
    ├── pipes/                      # (same structure as wells)
    ├── masters/                    # MasterRepository, MastersManagePage
    ├── users/                      # UserRepository, UsersManagePage (super-admin)
    ├── cities/                     # CityRepository, CitiesManagePage (super-admin)
    ├── settings/                   # SettingsPage
    └── audit/                      # AuditLogPage (super-admin)
```

Test:
```
test/
├── core/
├── features/
│   ├── auth/
│   ├── wells/
│   └── pipes/
└── helpers/
```

## 3. Layered arxitektura (har feature ichida)

```
presentation/ → application/ → domain/ ← data/
```

| Qatlam | Mas'ul | Bilmaydi |
|---|---|---|
| `presentation/` | Widget'lar, page'lar, navigation | Firestore, Repository |
| `application/` | Riverpod provider'lar, form controller'lar, business orchestratsiya | Widget detallari, Firestore qanday tuzilganligi |
| `domain/` | Pure Dart entity'lar, value object'lar, enum'lar, business invariant'lar | Hech narsa (har joydan ishlatiladi) |
| `data/` | Repository (interface va Firebase impl), DTO ↔ Domain mappers | UI |

**Qoidalar:**
- `presentation/` faqat `application/` ga import qiladi. Hech qachon `data/` ga to'g'ridan-to'g'ri kirmaydi.
- `data/` faqat `domain/` ga import qiladi. UI'ni bilmaydi.
- `domain/` hech qaerga import qilmaydi (Flutter/Firebase kutubxonalarisiz).

## 4. State management — Riverpod

Faqat **code-generated** Riverpod ishlatamiz:

```dart
// features/wells/application/wells_providers.dart
@riverpod
Stream<List<Well>> wellsStream(WellsStreamRef ref, String cityId) {
  return ref.watch(wellRepositoryProvider).watchAll(cityId);
}

@riverpod
class WellFormController extends _$WellFormController {
  @override
  WellFormState build(String? wellId) => WellFormState.initial(wellId);

  void updateStatus(WellStatus status) =>
      state = state.copyWith(status: status);

  Future<void> save() async { /* ... */ }
}
```

**Qoidalar:**
- Global mutable state YO'Q. Hammasi provider orqali.
- `ref.read` faqat callback ichida. Build'da `ref.watch`.
- `ref.listen` faqat side-effect uchun (snackbar, navigation).
- Provider nomi: `<noun>Provider` yoki `<verb><Noun>Provider`.
- Async state — `AsyncValue<T>` orqali. Loading/error state qo'lda emas.

## 5. Routing — go_router

```dart
// core/router/app_router.dart
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: ref.watch(authChangeNotifierProvider),
    redirect: _redirect,  // pass-key tekshirish, role-based redirect
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/map', builder: (_, __) => const MapHomePage()),
          GoRoute(
            path: '/wells/:wellId',
            builder: (_, st) => WellDetailPage(wellId: st.pathParameters['wellId']!),
          ),
          GoRoute(path: '/wells/new', builder: (_, __) => const WellCreateEditPage()),
          GoRoute(
            path: '/pipes/:pipeId',
            builder: (_, st) => PipeDetailPage(pipeId: st.pathParameters['pipeId']!),
          ),
          GoRoute(path: '/pipes/new', builder: (_, __) => const PipeCreateEditPage()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
          GoRoute(path: '/masters', builder: (_, __) => const MastersManagePage()),
          GoRoute(path: '/users', builder: (_, __) => const UsersManagePage()),    // super-admin
          GoRoute(path: '/cities', builder: (_, __) => const CitiesManagePage()),  // super-admin
          GoRoute(path: '/audit', builder: (_, __) => const AuditLogPage()),      // super-admin
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
        ],
      ),
    ],
  );
});
```

Route nomlari [pages/INDEX.md](pages/INDEX.md) bilan moslashuvi shart.

## 6. Theme va dizayn

- Material 3.
- Light + Dark — har ikkisi shart.
- Brend rangi: **kabel-ko'k** (`#0F66B0`) — keyin super-admin Settings'da o'zgartirsa bo'ladi (faza 2).
- Font: System default. Maxsus font qo'shmaymiz.
- `AppSpacing` (4/8/12/16/24/32) — hardcode pixel YO'Q.

## 7. Mapping qoidalari (flutter_map + Yandex tiles)

- `FlutterMap` widget asosiy, `TileLayer` ichida Yandex tile URL:
  `https://core-renderer-tiles.maps.yandex.net/tiles?l=map&x={x}&y={y}&z={z}&scale=1&lang=ru_RU`
- Kolodets — `MarkerLayer` ichida `Marker` (yumaloq Container `BoxShape.circle`).
- Pipe — `PolylineLayer` ichida `Polyline`.
- Clustering — `flutter_map_marker_cluster` paketi (50+ marker bo'lganda).
- Map controller — `MapController` (per page, dispose qilinadi).
- Windows, Android, iOS — hammasi bir xil ishlaydi (pure Dart).

### Yandex tile servers haqida

- Bu yondashuv **rasmiy emas** — Yandex ToS bo'yicha kompaniya Yandex MapKit SDK orqali ishlatishni afzal ko'radi.
- Lekin bizning ichki ilovamiz (10-30 foydalanuvchi, ko'p emas, business app) uchun real xavf yo'q.
- Agar kelajakda ko'p foydalanuvchi yoki Google Play Store'ga e'lon qilish bo'lsa — Yandex API key bilan rasmiy SDK'ga ko'chish kerak.

## 8. Modellar — Freezed

Har domain entity Freezed bilan:

```dart
@freezed
class Well with _$Well {
  const factory Well({
    required String id,
    required String code,
    required GeoPoint location,
    required WellStatus status,
    required bool paid,
    DateTime? installedAt,
    String? masterId,
    String? notes,
    @Default([]) List<String> photoUrls,
    required DateTime createdAt,
    required String createdBy,
    required DateTime updatedAt,
    required String updatedBy,
  }) = _Well;

  factory Well.fromFirestore(DocumentSnapshot doc) { /* mapper */ }
  Map<String, dynamic> toFirestore() { /* mapper */ }
}
```

`fromFirestore` / `toFirestore` `data/` repositoryda yashaydi, domain ichida emas. (Freezed `domain/` da bo'ladi, mapper `data/` da.)

## 9. Errors

`core/errors/`:
- `AppException` — base
- `NetworkException`, `PermissionDeniedException`, `NotFoundException`, `ValidationException`
- `ErrorMapper.fromFirebase(FirebaseException)` — Firebase xatolarni AppException'ga aylantiradi

UI darajada: `AsyncValue.when(error: ...)` ichida `ErrorView(exception)` ko'rsatadi.

## 10. Logging

`core/logging/AppLogger`:
- `debug` / `info` / `warn` / `error`
- Console'ga doim chiqaradi
- `warn` va `error` — Firestore `logs/` collectionga ham yozadi (audit uchun)
- PII (telefon, ism) log'larga tushmaydi — faqat ID'lar

## 11. Konfiguratsiya (env)

`lib/core/config/app_config.dart`:
```dart
class AppConfig {
  static const yandexMapsApiKey = String.fromEnvironment('YANDEX_MAPS_API_KEY');
  static const firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  // ...
}
```

Run: `flutter run --dart-define-from-file=.env.json`

`.env.json` git'ga tushmaydi (`.gitignore`).

## 12. Build va deploy

- Android: `flutter build apk --release --dart-define-from-file=.env.production.json`
- Windows: `flutter build windows --release --dart-define-from-file=.env.production.json`
- Cloud Functions: `firebase deploy --only functions`
- Firestore rules: `firebase deploy --only firestore:rules,firestore:indexes`
- Storage rules: `firebase deploy --only storage`

To'liq qo'llanma: [WORKFLOW.md](WORKFLOW.md) → "Deploy" bo'limi.

---

**Keyingi o'qish:** [FIREBASE.md](FIREBASE.md)
