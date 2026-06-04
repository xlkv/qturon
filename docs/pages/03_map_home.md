# 03_map_home.md — Asosiy xarita sahifa

> Marshrut: `/map` · Role: hammada (lekin ko'rinish/o'zgartirish role'ga qarab) · Status: TODO
> Index: [INDEX.md](INDEX.md)

---

## 1. Maqsad

Ilovaning **uy sahifasi**. Yandex Maps'da:
- Kolodets'lar — yumaloq markerlar (kod yorlig'i bilan).
- Turbalar — polyline'lar.
- Filter, search, yangi qo'shish, navigatsiya.

## 2. UI

### AppBar
- Sarlavha: hozirgi shahar nomi.
- Super-admin uchun: shahar nomi tugma (dropdown — boshqa shaharga o'tish).
- Trailing actions:
  - **Search** icon (kolodets `code` yoki turba `code` bo'yicha)
  - **Filter** icon (status checkbox'lar, `paid` faqat super-admin uchun)
  - **Profile/Menu** icon (Drawer ochadi)

### Body (asosiy)
- `YandexMap` widget — to'liq ekran.
- Markerlar va polyline'lar `MapObject` orqali qo'shiladi.

### FAB
Pastki o'ngda:
- super_admin va admin uchun: 2 ta mini-FAB (animatsiyali ochiladi):
  - Yangi kolodets qo'shish → tap mode'ga o'tadi (xarita tap qilinganda `/wells/new?lat=...&lng=...`)
  - Yangi turba qo'shish → drawing mode'ga o'tadi
- user uchun: FAB yo'q

### Bottom sheet (peek)
- Kolodets/turba'ga bosilganda — bottom sheet ochiladi (200dp peek).
- Peek'da: kod, status badge, master ismi, "Batafsil" tugma.
- "Batafsil" → `/wells/:id` yoki `/pipes/:id`.

### Drawer (chap chap menyu)
- Foydalanuvchi ismi + role
- Marshrut linklari:
  - Xarita (faol)
  - Masters (admin+)
  - Users (super_admin)
  - Cities (super_admin)
  - Audit log (super_admin)
  - Settings
  - Profile / Logout

## 3. State

### Provider'lar
```dart
@riverpod
Stream<List<Well>> wellsStream(WellsStreamRef ref, String cityId);

@riverpod
Stream<List<Pipe>> pipesStream(PipesStreamRef ref, String cityId);

@riverpod
class MapFilter extends _$MapFilter {
  @override
  MapFilterState build(String cityId) => MapFilterState.defaults();
  void toggleStatus(WellStatus s);
  void setSearchQuery(String q);
  void setShowOnlyPaid(bool v);  // faqat super-admin
}

@riverpod
class MapDrawingMode extends _$MapDrawingMode {
  @override
  DrawingMode build() => DrawingMode.none;
  void startWellPlacement();
  void startPipeDrawing();
  void addPipePoint(GeoPoint p);
  void finishPipe();
  void cancel();
}
```

### Holatlar
```dart
enum DrawingMode { none, wellPlacement, pipeDrawing }

class MapFilterState {
  final Set<WellStatus> statuses;     // bo'sh = hammasi
  final String? searchQuery;
  final bool showOnlyPaid;            // faqat super-admin uchun
}
```

## 4. Logika

### Markerlarni filterlash
```dart
final wells = ref.watch(wellsStreamProvider(cityId)).value ?? [];
final filter = ref.watch(mapFilterProvider(cityId));
final visible = wells.where((w) {
  if (filter.statuses.isNotEmpty && !filter.statuses.contains(w.status)) return false;
  if (filter.searchQuery != null && !w.code.toLowerCase().contains(filter.searchQuery!.toLowerCase())) return false;
  return true;
}).toList();
```

> Repository allaqachon `paid: true` filter qo'yadi non-super-admin uchun (rules ham). Bu yerda qo'shimcha emas.

### Marker tap
```dart
onWellTap: (well) {
  showModalBottomSheet(...);  // peek
  // tap "Batafsil": context.push('/wells/${well.id}')
}
```

### Yangi kolodets qo'shish (DrawingMode.wellPlacement)
1. FAB bosilgan → mode = wellPlacement, kursor cross-hair, snackbar "Joyni tanlang"
2. Xarita tap → `context.push('/wells/new?lat=$lat&lng=$lng&cityId=$cityId')`
3. Form sahifasi ochiladi (05_well_create_edit.md)
4. Mode'ni `none` ga qaytaring (form sahifasi ochilgach controllerda).

### Yangi turba chizish
1. FAB bosilgan → mode = pipeDrawing, snackbar "Nuqtalarni belgilang. Tugatish uchun pastdagi 'Tugatish' tugmasini bosing."
2. Xarita tap har biriga `addPipePoint`. Polyline real-time chiziladi (preview rangda).
3. Pastda 2 ta tugma: **Bekor qil** / **Tugatish (N nuqta)**.
4. Tugatish (min 2 nuqta) → `/pipes/new?cityId=...&points=lat1,lng1;lat2,lng2;...`.

## 5. Firestore o'qish/yozish

- O'qish: `cities/{cityId}/wells`, `cities/{cityId}/pipes` — stream (snapshot listener).
- Yozish: yo'q (form sahifasida bo'ladi).

## 6. Permission

| Element | super_admin | admin | user |
|---|---|---|---|
| Xarita ko'rish | ✓ | ✓ | ✓ |
| Marker/Pipe ko'rish (paid:true) | ✓ | ✓ | ✓ |
| Marker/Pipe ko'rish (paid:false) | ✓ | ✗ | ✗ |
| Filter "Faqat to'langan" | ✓ | (yo'q — doim true) | (yo'q) |
| Yangi qo'shish (FAB) | ✓ | ✓ | ✗ |
| Shahar tanlash dropdown | ✓ | ✗ (1 shaharga bog'langan) | ✗ |
| Drawer: Users | ✓ | ✗ | ✗ |
| Drawer: Cities | ✓ | ✗ | ✗ |
| Drawer: Audit | ✓ | ✗ | ✗ |

## 7. Edge case

| Holat | Harakat |
|---|---|
| Hech shahar mavjud emas (super-admin birinchi run) | Empty state: "Hali shahar qo'shilmagan" + tugma "Shahar qo'shish" → `/cities` |
| User'ning cityId bo'sh | Empty state: "Sizga shahar tayinlanmagan. Super-admin bilan bog'laning." |
| Marker juda ko'p (1000+) | Clustering yoqiladi |
| Tarmoq yo'q | Firestore offline cache'dan oxirgi snapshot ko'rsatadi + banner "Internet yo'q" |
| Yandex MapKit init xato | Fallback "Xarita yuklanmadi. Ilovani qayta oching." |
| Search'da topilmadi | Pastda toast "Topilmadi" |

## 8. Performance

- `wellsStream` snapshot'lar — limit 5000 (city ichida). Ko'proq bo'lsa pagination kerak.
- Marker render — `ClusterizedPlacemarkCollection` 50+ markerda.
- Filter — client-side (data already cached).

## 9. Aloqador hujjatlar

- [../FIREBASE.md §2](../FIREBASE.md) — wells/pipes schema
- [../AUTH_AND_ROLES.md §3.1](../AUTH_AND_ROLES.md) — kim nimani ko'radi
- [04_well_detail.md](04_well_detail.md) — marker tap natijasi
- [06_pipe_detail.md](06_pipe_detail.md) — polyline tap
- [05_well_create_edit.md](05_well_create_edit.md), [07_pipe_create_edit.md](07_pipe_create_edit.md) — FAB destinatsiya

## 10. Build prompt

```
docs/README.md ni o'qing va so'ngra docs/pages/03_map_home.md ni to'liq o'qing.
docs/FIREBASE.md §2 va docs/AUTH_AND_ROLES.md §3 ga ham qarang.

Vazifa: MapHomePage'ni qurish. Yandex MapKit'ni o'rnatish.

Joylashuv:
- lib/features/map/presentation/map_home_page.dart
- lib/features/map/presentation/widgets/well_marker.dart
- lib/features/map/presentation/widgets/pipe_polyline.dart
- lib/features/map/presentation/widgets/map_filter_sheet.dart
- lib/features/map/presentation/widgets/well_peek_sheet.dart
- lib/features/map/presentation/widgets/pipe_peek_sheet.dart
- lib/features/map/application/map_filter.dart
- lib/features/map/application/map_drawing_mode.dart
- lib/features/wells/application/wells_stream.dart
- lib/features/pipes/application/pipes_stream.dart

Bosqichlar (bir-biriga zid bermaslik uchun shu tartibda):
1. Yandex MapKit qo'shish (pubspec, android setup, .env API key)
2. Provider'larni yarating (wellsStream, pipesStream, mapFilter, mapDrawingMode)
3. MapHomePage skeleti — AppBar + YandexMap + FAB + Drawer (faqat stub)
4. Markerlar render qilish
5. Polyline render qilish
6. Bottom sheet (peek) implementatsiyasi
7. Filter sheet
8. FAB yordamida drawing mode (well placement + pipe drawing)
9. Drawer'dagi navigation linklari

Permission: ref.watch(permissionsProvider) orqali FAB va Drawer item'larni shartlashtiring.

Code rules:
- Riverpod codegen, freezed states
- AppSpacing ishlatish, no hardcoded EdgeInsets
- Logger orqali "map.well_tap" va boshqa eventlar log qilinsin

Tugatgach:
- Status: DONE → pages/03_map_home.md va INDEX.md
- logs/CHANGELOG.md ga yozing
```

## Status

TODO
