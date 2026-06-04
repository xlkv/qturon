# 13_audit_log.md — Audit log (super_admin)

> Marshrut: `/audit` · Role: super_admin · Status: TODO
> Index: [INDEX.md](INDEX.md)

---

## 1. Maqsad

Tizimdagi hamma harakatlarni ko'rib chiqish: kim, qachon, nima qildi.

## 2. UI

### AppBar
- Sarlavha: `Audit log`
- Trailing: **Filter** (icon)

### Body
- `ListView` (pagination, 50 per page):
  - Item: timestamp + userName + action + entityType + entityId (qisqacha)
  - Tap → expand: changes (before/after JSON), message
- Filter sheet: sana oralig'i, action turi, entity turi, user, shahar

## 3. State

```dart
@riverpod
class AuditLogController extends _$AuditLogController {
  @override
  AuditLogState build() => AuditLogState.initial();
  Future<void> loadMore();
  void updateFilter(AuditLogFilter f);
}
```

`AuditLogRepository`:
- `query(filter, {limit, startAfter})` → `cities/.../logs` yoki `/logs` global

Pagination — Firestore `startAfterDocument`.

## 4. Logika

- Filter o'zgarsa — reset + qayta yuklash.
- Scroll bottom'ga yetganda — `loadMore()`.

## 5. Firestore

- O'qish: `/logs` collection, indexlar `timestamp DESC`, kerak bo'lsa `cityId + timestamp`.
- Yozish: yo'q (faqat AppLogger va Cloud Functions yozadi).

## 6. Permission

Faqat super_admin. Router guard.

## 7. Aloqador

- [../FIREBASE.md §2 — /logs](../FIREBASE.md)

## 8. Build prompt

```
docs/README.md, docs/pages/13_audit_log.md, docs/FIREBASE.md §2 ni o'qing.

Vazifa: AuditLogPage + AuditLogRepository + AuditLogController.

Joylashuv:
- lib/features/audit/presentation/audit_log_page.dart
- lib/features/audit/presentation/widgets/audit_log_filter_sheet.dart
- lib/features/audit/application/audit_log_controller.dart
- lib/features/audit/data/audit_log_repository.dart
- lib/features/audit/domain/audit_event.dart (freezed)

Talab:
1. Router guard (super_admin only).
2. Pagination — Firestore startAfter.
3. Filter: sana oralig'i (DateRange), action, entity, userId, cityId.
4. List item — kompakt; tap'da expand JSON.
5. Empty state.

Code rules: standart.

Tugatgach: Status DONE + INDEX + CHANGELOG.
```

## Status

TODO
