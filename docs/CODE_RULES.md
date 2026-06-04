# CODE_RULES.md

> Kod yozishda majburiy qoidalar. Vibe-coding bo'lsa ham — chiziqsiz emas.
> Oldingi: [AUTH_AND_ROLES.md](AUTH_AND_ROLES.md) · Keyingi: [WORKFLOW.md](WORKFLOW.md)

---

## 1. Asosiy printsiplar

1. **Mavjud kodga moslang.** Yangi pattern qo'shishdan oldin shu papkadagi 2-3 ta yaqin faylga qarang.
2. **Hozir kerak — hozir yozing. Kelajak uchun "balki kerak bo'lar" — yozmang.** YAGNI.
3. **3 ta o'xshash qator — bu hali "abstraction" emas.** 3-4 marta takrorlangan logika faqat keyin metodga ko'chiriladi.
4. **Yarim ish qoldirmang.** Agar ulgurmasangiz, sahifa MD'siga `Status: WIP — sabab: ...` deb yozing.
5. **Comment yozish DEFAULT — yo'q.** Faqat "nima uchun" tushunarsiz bo'lsa 1 qator. "Nima qiladi" — kod nomidan tushuniladi.
6. **Backwards-compat shim — hech qachon.** Loyiha yangi, eski kod yo'q.

## 2. Naming (Dart)

| Element | Naming | Misol |
|---|---|---|
| File | `snake_case.dart` | `well_repository.dart` |
| Class | `UpperCamelCase` | `WellRepository` |
| Mixin | `UpperCamelCase` | `LoggingMixin` |
| Enum | `UpperCamelCase` (qiymatlar `lowerCamelCase`) | `WellStatus.planned` |
| Method/var | `lowerCamelCase` | `watchAllWells` |
| Const | `lowerCamelCase` (Dart konvensiyasi) | `defaultZoom` |
| Private | `_` prefix | `_mapWells` |
| Generated file | `*.g.dart`, `*.freezed.dart` | `well.freezed.dart` |
| Test | `*_test.dart` | `well_repository_test.dart` |

> Inglizcha ishlating kod ichida. UI matnlari faqat o'zbekcha.

## 3. Fayl tartibi

Har fayl shu tartibda:
1. License/copyright (yo'q — kerak emas)
2. Import (3 guruh, har birida alfavit):
   - `dart:` paketlari
   - `package:` paketlari
   - Project nisbiy (`../`, `./`)
3. `part 'file.g.dart';` (codegen)
4. Top-level konstantalar
5. Public classes/functions
6. Private classes/functions

Hech qachon import'lar orasida bo'sh qator yo'q. Guruhlar orasida — bor.

## 4. Riverpod qoidalari

### 4.1 Faqat code-generated provider

```dart
// XATO
final wellsProvider = StreamProvider.family<List<Well>, String>((ref, cityId) { ... });

// TO'G'RI
@riverpod
Stream<List<Well>> wellsStream(WellsStreamRef ref, String cityId) {
  return ref.watch(wellRepositoryProvider).watchAll(cityId);
}
```

### 4.2 build/ref qoidalari

| Hol | Tool |
|---|---|
| Build vaqtida boshqa provider'ni o'qish | `ref.watch` |
| Callback ichida boshqa provider'ni o'qish | `ref.read` |
| Side-effect (snackbar, navigation) | `ref.listen` |

### 4.3 Async — `AsyncValue` orqali

```dart
ref.watch(wellsStreamProvider(cityId)).when(
  data: (wells) => WellList(wells: wells),
  loading: () => const LoadingView(),
  error: (e, st) => ErrorView(error: e),
);
```

Hech qachon qo'lda `isLoading`, `error`, `data` state yozmang.

### 4.4 Controller pattern

Form yoki kompleks state uchun `Notifier` (yoki `AsyncNotifier`):

```dart
@riverpod
class WellFormController extends _$WellFormController {
  @override
  WellFormState build(String? wellId) {
    if (wellId == null) return WellFormState.empty();
    return WellFormState.fromExisting(/* ... */);
  }

  void updateNotes(String notes) => state = state.copyWith(notes: notes);

  Future<void> submit() async {
    state = state.copyWith(isSubmitting: true);
    try {
      await ref.read(wellRepositoryProvider).save(state.toWell());
      state = state.copyWith(isSubmitting: false, savedOk: true);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e);
    }
  }
}
```

### 4.5 Provider scope

- Auth/Theme/Config — `keepAlive: true`
- Sahifa-spesifik (form) — default (sahifa yopilganda dispose)

## 5. Model qoidalari (Freezed)

- Hamma domain model `@freezed` bilan immutable.
- `copyWith`, `==`, `hashCode`, `toString` — bepul.
- Field default qiymat — `@Default(...)`. Migration uchun foydali.
- Firestore mapper (`fromFirestore`/`toFirestore`) **alohida extension** yoki **`data/` qatlamida** turadi, **domain ichida emas** — domain Firestore'ni bilmaydi.

```dart
// domain/well.dart
@freezed
class Well with _$Well { /* fields */ }

// data/mappers/well_firestore_mapper.dart
extension WellFirestoreMapper on Well {
  static Well fromFirestore(DocumentSnapshot doc) { /* ... */ }
  Map<String, dynamic> toFirestore() { /* ... */ }
}
```

## 6. Error handling

### 6.1 Repository darajasi

Firebase xatosini `AppException`ga aylantiring:

```dart
try {
  await _firestore.doc(...).set(...);
} on FirebaseException catch (e) {
  throw ErrorMapper.fromFirebase(e);
}
```

### 6.2 Controller darajasi

Try/catch faqat user'ga ko'rsatish kerak bo'lganda:

```dart
Future<void> submit() async {
  try { /* ... */ } catch (e) {
    state = state.copyWith(error: e is AppException ? e : AppException.unknown(e));
  }
}
```

### 6.3 UI darajasi

`AsyncValue.when(error: ...)` yoki controller state ichidagi `error` ko'rsatiladi. **Bir xatoni 2 joyda ushlamang.**

### 6.4 Hech qachon

- `catch` ichida log + qaytatanaglatmang. Yo log qiling va yutib yuboring, yo qaytar — ikkalasini emas.
- Bo'sh `catch (_) {}` — taqiqlangan.
- `try` ichida UI navigatsiya qilmang — `then` yoki `await`'dan keyin.

## 7. Logging qoidalari

```dart
ref.read(loggerProvider).info('well_created', {'wellId': well.id, 'cityId': cityId});
ref.read(loggerProvider).warn('photo_upload_retry', {'attempt': 2});
ref.read(loggerProvider).error('save_failed', error, stackTrace);
```

- **PII yo'q**: ism, telefon, pass-key — log'ga tushmaydi. Faqat ID.
- `warn` va `error` Firestore'ga ham yoziladi (`/logs`).
- `debug` — faqat console.

## 8. Comment va dokumentatsiya

### 8.1 Yozmang (default)

```dart
// XATO — ko'p shovqin
// Get user from provider
final user = ref.watch(currentUserProvider);

// Save well to repository
await repo.save(well);
```

### 8.2 Yozing — agar "nima uchun" noaniq

```dart
// Firestore transaction'siz race condition: 2 ta foydalanuvchi
// bir vaqtda B5 yaratishi mumkin. Counter doc'ni transaction bilan o'qiymiz.
final code = await _firestore.runTransaction((tx) async { /* ... */ });
```

### 8.3 Doc-comment (`///`)

- Public API uchun (boshqa fayl import qiladigan funksiya/class).
- 1-3 qator. Misol berishni hohlasangiz — 1 ta misol.

### 8.4 TAQIQLANGAN

- `// removed: ...` (eski kod izi yo'q)
- `// added for issue X` (PR description'da yashasin)
- `// TODO: kerak bo'lsa ...` (kerak bo'lganda yozasiz)

## 9. Imports

- Relative import (`../../foo.dart`) — ENG QISQA yo'l bo'lganda.
- Cross-feature import — `package:turon_suv/features/wells/...`.
- `part of` faqat codegen uchun.

## 10. Widget qoidalari

### 10.1 Stateless avval

Default — `StatelessWidget`. State kerak bo'lsa Riverpod (`ConsumerWidget`).

### 10.2 StatefulWidget — faqat lokal UI state uchun

- `TextEditingController`, `ScrollController`, `AnimationController` lifecycle.
- Domain state'ni shu yerga qo'ymang — Riverpod controller'ga.

### 10.3 Build method

- 30 qatordan ko'p bo'lsa — bo'lib tashlang (yangi widget yoki private method).
- Boshlanish: `ConsumerWidget`, `ref.watch(...)`, build derevasi.

### 10.4 const widgets

Iloji boricha `const`. Code lints buni majbur qiladi.

### 10.5 Reusable widgets

`core/widgets/` ichiga — agar 3+ joyda ishlatilsa.

## 11. Forma validation

- Form-level: `Form` + `GlobalKey<FormState>`.
- Field-level: `TextFormField.validator: (v) => Validators.required(v)`.
- Validator'lar `core/utils/validators.dart` da:

```dart
class Validators {
  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Bo\'sh bo\'lmasligi kerak' : null;

  static String? passKey(String? v) =>
      (v == null || !RegExp(r'^\d{6}$').hasMatch(v))
          ? '6 xonali raqam kiriting' : null;

  static String? positiveNumber(String? v) {
    final n = double.tryParse(v ?? '');
    return (n == null || n <= 0) ? 'Musbat son kiriting' : null;
  }
}
```

## 12. Theme va spacing

`core/theme/app_spacing.dart`:
```dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}
```

Hech qaerda `Padding(EdgeInsets.all(13))` yozmang. `AppSpacing.md` ishlating.

Color, TextStyle — `Theme.of(context).colorScheme.primary` orqali. Hardcode `Color(0xFFF...)` faqat `app_colors.dart` ichida.

## 13. Async va Future qoidalari

- `async`/`await` — default. `.then(...)` kerak emas.
- Long-running operation oldidan `ref.read(loadingProvider.notifier).start()`.
- `Future.wait([...])` — parallel mumkin bo'lgan operatsiyalar uchun.
- Hech qachon `async` bo'lgan callback'da `unawaited(...)`'siz Future qoldirmang.

## 14. Test

### 14.1 Ko'rsatma (MVP'da hozircha kerak emas, lekin patternni saqlang)

- Unit: `flutter_test` + `mocktail`.
- Widget: `tester.pumpWidget(ProviderScope(overrides: [...], child: ...))`.
- Test fayl shu papkada `test/` ichida bir xil yo'l.

### 14.2 Coverage

MVP'da hech narsa talab qilinmaydi. Faza 2: kritik biznes logikaga (`well_repository`, `auth_controller`, permission matrisasi) 70%+.

## 15. Lints

`analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    avoid_print: true
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    prefer_final_locals: true
    prefer_single_quotes: true
    require_trailing_commas: true
    use_key_in_widget_constructors: true
    avoid_dynamic_calls: true
    avoid_returning_null_for_future: true
    unawaited_futures: true

analyzer:
  errors:
    invalid_annotation_target: ignore
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "lib/firebase_options.dart"
```

`dart analyze` har commit oldidan toza bo'lishi shart (warning'sizroq).

## 16. Commit konvensiyasi

```
type(scope): qisqa qator (50 chars maks)

[bo'sh qator]
[batafsil — agar kerak bo'lsa]
```

Types: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`, `style`.

Misol: `feat(wells): yangi kolodets yaratish formasi`

## 17. Refactor qachon

| Belgi | Harakat |
|---|---|
| Bir funksiya 50+ qator | Bo'ling — lekin **yangi funksiya nomi mantiqli** bo'lishi shart |
| 1 ta widget 200+ qator | Sub-widget'larga bo'ling |
| 3 marta o'xshash code | Extract |
| Imports 30+ qator | Feature noto'g'ri yotgan — qaytadan tartiblang |

> Refactor — vazifa tugagandan **keyin**, vazifa o'rtasida emas.

## 18. Gitignore

Asosiy `.gitignore` da:
- `.env*.json`
- `**/google-services.json` (real)
- `**/GoogleService-Info.plist` (real)
- `lib/firebase_options.dart` (yoki commit, lekin sirlarsiz — public webApiKey OK)
- `*.g.dart`, `*.freezed.dart` — **commit qiling** (build_runner output ham repo'da)

> Generated fayl'larni commit qilamiz — CI build'da chalkashlik kamayadi va `pub get`'dan keyin barcha narsa darhol ishlaydi.

## 19. Performance

- Map'da 1000+ marker bo'lganda clustering majburiy.
- Firestore query'larda har doim `limit(...)`.
- Pagination: `startAfterDocument` (Firestore native).
- List uchun `ListView.builder` (yoki `SliverList`).

## 20. Sirlar (secrets)

Hech qachon kod ichiga sir qo'ymang:
- API key — `String.fromEnvironment` orqali
- Pass-key — Firestore'da (`/users`)
- Cloud Function key — Functions secrets manager (`process.env.X`)

---

**Keyingi o'qish:** [WORKFLOW.md](WORKFLOW.md)
