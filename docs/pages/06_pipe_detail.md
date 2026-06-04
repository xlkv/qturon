# 06_pipe_detail.md — Turba detallari

> Marshrut: `/pipes/:pipeId` · Role: hammada (paid:true bo'lsa) · Status: TODO
> Index: [INDEX.md](INDEX.md)

---

## 1. Maqsad

Bitta turba haqida to'liq ma'lumot. Read-only (user) yoki edit imkoniyatli (admin, super_admin).

Edit alohida — [07_pipe_create_edit.md](07_pipe_create_edit.md).

> Struktura va xulq-atvor bo'yicha [04_well_detail.md](04_well_detail.md) ga juda yaqin. Bu yerda faqat **farqlar** batafsilroq.

## 2. UI farqlari (well detail'dan)

- **Joylashuv** o'rniga — **Polyline preview** (kichik harita, chiziq ko'rinadi).
- Qo'shimcha satrlar:
  - **Diametri**: `110 mm`
  - **Uzunligi**: `42.5 m` (sariq belgi: agar polyline geo-length'idan farqi 10%+ bo'lsa — "geo-uzunlik: 38.2 m" subscript)
  - **Nuqtalar soni**: `3 ta` (`points` list uzunligi)

Boshqa hamma narsa well detail bilan bir xil (status, master, installedAt, notes, photos, paid).

## 3. State

```dart
@riverpod
Stream<Pipe?> pipe(PipeRef ref, String cityId, String pipeId);

@riverpod
Future<Master?> masterById(MasterByIdRef ref, String cityId, String? masterId);  // wells'dan reuse
```

`PipeRepository`:
- `watch(cityId, pipeId)`
- `delete(cityId, pipeId)`
- `nextCode(cityId)` → `P1`, `P2`, ...

## 4. Polyline preview

Kichik `YandexMap` (tap'lar disabled, scroll disabled):
- Camera fit: `points` bounding box + padding 20%.
- Polyline ranga: status'ga qarab (planned=kulrang, working=ko'k, done=yashil).

## 5. Geo length hisoblash

Haversine:
```dart
double geoLengthMeters(List<GeoPoint> pts) {
  double sum = 0;
  for (var i = 1; i < pts.length; i++) {
    sum += DistanceUtils.haversine(pts[i-1], pts[i]);
  }
  return sum;
}
```

`core/utils/distance.dart` — Haversine formula.

## 6. Permission

[04_well_detail.md](04_well_detail.md) bilan bir xil.

## 7. Aloqador

- [07_pipe_create_edit.md](07_pipe_create_edit.md)
- [../FIREBASE.md §2](../FIREBASE.md) — pipe schema

## 8. Build prompt

```
docs/README.md, docs/pages/06_pipe_detail.md, docs/pages/04_well_detail.md ni o'qing.

Vazifa: PipeDetailPage (well_detail'ga juda o'xshash).

Joylashuv:
- lib/features/pipes/presentation/pipe_detail_page.dart
- lib/features/pipes/presentation/widgets/pipe_info_list.dart
- lib/features/pipes/presentation/widgets/polyline_preview.dart
- lib/features/pipes/application/pipe_provider.dart
- lib/features/pipes/data/pipe_repository.dart
- lib/core/utils/distance.dart (haversine)

Talab:
1. pipeStreamProvider — single doc snapshot.
2. PolylinePreview — kichik YandexMap (statik, fit bounds), polyline rangi status'ga bog'liq.
3. Info list: code, status chip, diameterMm, lengthM (geo length comparisons), points count, master, installedAt, notes, paid (perms).
4. Photo carousel — reusable PhotoCarousel widget (wells'dan).
5. Edit/Delete tugmalari permsga qarab.
6. Logger event.

Code rules: standart.

Tugatgach: Status DONE, INDEX, CHANGELOG.
```

## Status

TODO
