# pages/INDEX.md

> Barcha sahifalar ro'yxati va status.
> Kirish: [../README.md](../README.md) · Oldingi: [../WORKFLOW.md](../WORKFLOW.md)

---

## Ko'rinish

Har sahifa o'z MD'siga ega. Tartibi taxminan flow bo'yicha (Splash → Login → Map → ...). Raqamlar **tartib** bildiradi, **navigation** emas — har sahifa har qachon ochilishi mumkin.

## Sahifalar jadvali

| # | Fayl | Marshrut | Role | Status |
|---|---|---|---|---|
| 01 | [01_splash.md](01_splash.md) | `/splash` | hammada | DONE |
| 02 | [02_login_passkey.md](02_login_passkey.md) | `/login` | hammada | DONE |
| 03 | [03_map_home.md](03_map_home.md) | `/map` | hammada | TODO |
| 04 | [04_well_detail.md](04_well_detail.md) | `/wells/:id` | hammada | TODO |
| 05 | [05_well_create_edit.md](05_well_create_edit.md) | `/wells/new`, `/wells/:id/edit` | super_admin, admin | TODO |
| 06 | [06_pipe_detail.md](06_pipe_detail.md) | `/pipes/:id` | hammada | TODO |
| 07 | [07_pipe_create_edit.md](07_pipe_create_edit.md) | `/pipes/new`, `/pipes/:id/edit` | super_admin, admin | TODO |
| 08 | [08_settings.md](08_settings.md) | `/settings` | hammada | TODO |
| 09 | [09_masters_manage.md](09_masters_manage.md) | `/masters` | super_admin, admin | TODO |
| 10 | [10_users_manage.md](10_users_manage.md) | `/users` | super_admin | TODO |
| 11 | [11_cities_manage.md](11_cities_manage.md) | `/cities` | super_admin | TODO |
| 12 | [12_profile.md](12_profile.md) | `/profile` | hammada | TODO |
| 13 | [13_audit_log.md](13_audit_log.md) | `/audit` | super_admin | TODO |

## Sprint tartibi (tavsiya)

[Workflow §5](../WORKFLOW.md) ga qarang. Asosiy yo'l:

```
01 Splash → 02 Login → 11 Cities (super-admin) → 03 Map →
05 Well create → 04 Well detail → 07 Pipe create → 06 Pipe detail →
09 Masters → 10 Users → 12 Profile → 08 Settings → 13 Audit
```

## Status legend

- **TODO** — hali boshlanmagan
- **WIP** — boshlangan, qaysi qismi tayyor — sahifa MD'sida
- **DONE** — bajarilgan, MD bilan kod sinxron
- **BLOCKED** — boshqa narsaga bog'liq, kutyapti

Statusni har sahifaning o'z MD'sida `## Status` bo'limida ham yozing va shu yerda jadvalda yangilang.

## Yangi sahifa qo'shish

[../WORKFLOW.md §4](../WORKFLOW.md) ga qarang. Shablon: [../prompts/PROMPT_TEMPLATE.md](../prompts/PROMPT_TEMPLATE.md).
