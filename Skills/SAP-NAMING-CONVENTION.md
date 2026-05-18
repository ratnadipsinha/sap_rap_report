---
name: sap-naming-convention
description: SAP ABAP naming convention enforcer. Use when generating, reviewing, or naming any custom ABAP object. All custom objects must start with ZXX_. Triggers on object naming, package creation, CDS views, classes, tables, or any Z* artifact.
argument-hint: "[review | generate | list] <object-type or code>"
---

# SAP ABAP Naming Convention

All custom objects use the namespace prefix **`ZXX_`**.

---

## Master Prefix Rule

```
ZXX_<ObjectType><Name>
 │    │           └── Descriptive name in PascalCase or UPPER_SNAKE
 │    └── Object type indicator (see table below)
 └── Company namespace — ALWAYS ZXX_
```

> Never use plain `Z_`, `ZZ_`, or customer prefix without `XX_`.
> Never use `Y*` namespace.

---

## Object Type Prefix Reference

### Database & Dictionary

| Object | Prefix | Example |
|--------|--------|---------|
| Database Table | `ZXX_` | `ZXX_TRAVEL` |
| Draft Table | `ZXX_D_` | `ZXX_D_TRAVEL` |
| CDS Table Function | `ZXX_TF_` | `ZXX_TF_TRAVEL_CALC` |
| Domain | `ZXX_D_` | `ZXX_D_STATUS` |
| Data Element | `ZXX_E_` | `ZXX_E_TRAVEL_ID` |
| Structure | `ZXX_S_` | `ZXX_S_TRAVEL_KEY` |
| Type Group | `ZXX_T_` | `ZXX_T_TRAVEL` |
| Search Help | `ZXX_SH_` | `ZXX_SH_AGENCY` |

### CDS Views

| Object | Prefix | Example |
|--------|--------|---------|
| Interface View (root) | `ZXX_I_` | `ZXX_I_Travel` |
| Interface View (child) | `ZXX_I_` | `ZXX_I_TravelItem` |
| Projection View (root) | `ZXX_C_` | `ZXX_C_Travel` |
| Projection View (child) | `ZXX_C_` | `ZXX_C_TravelItem` |
| Value Help View | `ZXX_I_VH_` | `ZXX_I_VH_Agency` |
| Extension View | `ZXX_E_` | `ZXX_E_Travel` |
| Analytical View | `ZXX_A_` | `ZXX_A_TravelKPI` |

### RAP Behavior

| Object | Prefix | Example |
|--------|--------|---------|
| Behavior Definition | matches CDS view | `ZXX_I_Travel` (same name) |
| Behavior Implementation Class | `ZXX_BP_I_` | `ZXX_BP_I_Travel` |
| Projection Behavior Impl. | `ZXX_BP_C_` | `ZXX_BP_C_Travel` |
| Local Handler Class (CCIMP) | `lhc_` | `lhc_Travel` (local, no prefix) |
| Local Saver Class (CCIMP) | `lsc_` | `lsc_Travel` (local, no prefix) |

### Service

| Object | Prefix | Example |
|--------|--------|---------|
| Service Definition | `ZXX_UI_` | `ZXX_UI_Travel_O4` |
| Service Binding (OData V4 UI) | `ZXX_UI_` + `_O4` | `ZXX_UI_Travel_O4` |
| Service Binding (OData V2 UI) | `ZXX_UI_` + `_O2` | `ZXX_UI_Travel_O2` |
| Service Binding (Web API) | `ZXX_API_` | `ZXX_API_Travel_O4` |

### ABAP Classes & Interfaces

| Object | Prefix | Example |
|--------|--------|---------|
| Global Class | `ZXX_CL_` | `ZXX_CL_TravelHelper` |
| Global Interface | `ZXX_IF_` | `ZXX_IF_TravelValidator` |
| Exception Class | `ZXX_CX_` | `ZXX_CX_TravelError` |
| Test Class (ABAP Unit) | `ZXX_TC_` | `ZXX_TC_Travel` |
| ATC Custom Check Class | `ZXX_ATC_` | `ZXX_ATC_CleanCoreCheck` |

### Programs & Reports

| Object | Prefix | Example |
|--------|--------|---------|
| Report / Program | `ZXX_R_` | `ZXX_R_TravelReport` |
| Include | `ZXX_INC_` | `ZXX_INC_TravelMacros` |
| Function Group | `ZXX_FG_` | `ZXX_FG_TRAVEL` |
| Function Module | `ZXX_FM_` | `ZXX_FM_CALC_PRICE` |

### Enhancement & BAdI

| Object | Prefix | Example |
|--------|--------|---------|
| Enhancement Spot | `ZXX_ES_` | `ZXX_ES_TravelBO` |
| Enhancement Implementation | `ZXX_EI_` | `ZXX_EI_TravelBO` |
| BAdI Implementation Class | `ZXX_CL_BADI_` | `ZXX_CL_BADI_TravelSave` |

### Package & Transport

| Object | Prefix | Example |
|--------|--------|---------|
| Development Package | `ZXX_` | `ZXX_TRAVEL` |
| Sub-package | `ZXX_TRAVEL_` | `ZXX_TRAVEL_UI`, `ZXX_TRAVEL_BE` |

---

## Field Naming — Database Tables

```abap
" Table: ZXX_TRAVEL
travel_id        TYPE zxx_e_travel_id     " use custom data elements
agency_id        TYPE zxx_e_agency_id
overall_status   TYPE zxx_e_status
" Admin fields — always include these 5
created_by       TYPE syuname
created_at       TYPE utclong
last_changed_by  TYPE syuname
last_changed_at  TYPE utclong
local_last_changed_at TYPE utclong        " for ETag
```

## Field Naming — CDS Views

- Use **PascalCase** for CDS field aliases: `TravelId`, `AgencyId`, `OverallStatus`
- Alias must match the field name in behavior mapping
- Associations: prefix with `_` → `_Agency`, `_Customer`, `_Item`

```cds
define root view entity ZXX_I_Travel
  as select from zxx_travel as Travel
  association [0..1] to ZXX_I_Agency as _Agency on ...
{
  key travel_id     as TravelId,
      agency_id     as AgencyId,
      _Agency                        -- expose association
}
```

---

## Complete Object Set — Travel Example

```
Package:          ZXX_TRAVEL
  DB Tables:      ZXX_TRAVEL          ZXX_TRAVEL_ITEM
  Draft Tables:   ZXX_D_TRAVEL        ZXX_D_TRAVEL_ITEM
  Interface CDS:  ZXX_I_Travel        ZXX_I_TravelItem
  Projection CDS: ZXX_C_Travel        ZXX_C_TravelItem
  Value Help:     ZXX_I_VH_Agency     ZXX_I_VH_Customer
  BDEF:           ZXX_I_Travel        (same name as interface CDS)
  Impl. Class:    ZXX_BP_I_Travel
  Proj. BDEF:     ZXX_C_Travel        (same name as projection CDS)
  Service Def:    ZXX_UI_Travel_O4
  Service Bind:   ZXX_UI_Travel_O4
```

---

## Naming Checklist

```
[ ] All custom objects start with ZXX_
[ ] CDS interface views use ZXX_I_ prefix
[ ] CDS projection views use ZXX_C_ prefix
[ ] Value help views use ZXX_I_VH_ prefix
[ ] Behavior impl. class uses ZXX_BP_I_ or ZXX_BP_C_
[ ] Service definition / binding uses ZXX_UI_ (UI) or ZXX_API_ (API)
[ ] Global classes use ZXX_CL_, interfaces ZXX_IF_, exceptions ZXX_CX_
[ ] Database tables use ZXX_ only (no sub-prefix)
[ ] Draft table = DB table name + _D_ inserted: ZXX_D_<name>
[ ] CDS field aliases are PascalCase
[ ] Associations prefixed with underscore: _Agency, _Item
[ ] Package follows ZXX_<DOMAIN> pattern
[ ] No Y* objects, no plain Z_ objects
```

---

## Quick Reference Card

```
ZXX_          → DB table, package
ZXX_D_        → draft table, domain
ZXX_E_        → data element
ZXX_S_        → structure
ZXX_I_        → interface CDS view
ZXX_I_VH_     → value help CDS view
ZXX_C_        → projection CDS view
ZXX_A_        → analytical CDS view
ZXX_BP_I_     → behavior impl (interface)
ZXX_BP_C_     → behavior impl (projection)
ZXX_UI_       → service definition / binding (UI)
ZXX_API_      → service binding (Web API)
ZXX_CL_       → global class
ZXX_IF_       → global interface
ZXX_CX_       → exception class
ZXX_R_        → report / program
ZXX_ATC_      → custom ATC check class
ZXX_CL_BADI_  → BAdI implementation class
```
