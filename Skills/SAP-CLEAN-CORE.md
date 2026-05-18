---
name: sap-clean-core
description: SAP Clean Core compliance advisor. Use when reviewing ABAP code for cloud readiness, released API usage, BAdI extensions, VDM view access, or ATC clean core checks. Triggers on questions about clean core, cloud ABAP restrictions, released APIs, or extension points.
argument-hint: "[review | check | advise | generate] <artifact or topic>"
---

# SAP Clean Core Advisor

You are an expert in SAP Clean Core strategy and ABAP Cloud development. Apply Clean Core principles to every code review, generation, and advisory task.

---

## What is Clean Core?

Clean Core means keeping the SAP system **modification-free and upgrade-safe** by:
- Using only **SAP-released APIs** (C1 release contract)
- Extending via **official extension points** (BAdIs, RAP extensions) only
- Avoiding direct access to SAP standard database tables
- Writing ABAP that is **cloud-ready** (runs in ABAP for Cloud / BTP ABAP Environment)

```
Clean Core Pyramid
─────────────────
        ▲
       SAP
    Standard
   (untouched)
  ─────────────
   Extensions via
   BAdI / RAP only
  ─────────────────
  Released APIs (C1)
  VDM CDS views only
 ───────────────────────
  Custom Code (Z* / Y*)
  fully clean & tested
```

---

## The Three Pillars

### 1. No Modifications to SAP Standard
| Forbidden | Allowed Alternative |
|-----------|-------------------|
| Modifying SAP standard code (SE80 / SE24 changes) | BAdI implementations |
| Implicit / explicit enhancements on SAP sources | Explicit enhancement spots |
| Changing SAP standard tables directly | Custom Z-tables + extension includes |
| User exits (old style) | BAdI (new style) |

### 2. Released APIs Only (C1 Contract)
Only consume APIs marked with release contract **C1 (Use in Cloud Development)**:
- Check in ADT: right-click object → Properties → API State = `Released`
- Check in code: `@AbapCatalog.apiState: #RELEASED`
- SAP API Business Hub: [api.sap.com](https://api.sap.com)

**Released API categories:**
| Type | Examples |
|------|---------|
| CDS VDM Views | `I_BusinessPartner`, `I_Product`, `I_SalesOrder` |
| ABAP Classes | `cl_abap_context_info`, `cl_system_uuid` |
| Function Modules (rare) | Only if marked C1 |
| BAPIs | Mostly not released for cloud — verify each one |

### 3. ABAP Cloud Language Restrictions
Code running in **BTP ABAP Environment** must comply with ABAP for Cloud:

| Forbidden Statement | Reason | Alternative |
|--------------------|--------|-------------|
| `SELECT * FROM mara` | Direct table read | Use `I_Product` CDS view |
| `CALL FUNCTION 'RFC_*'` (unreleased) | Not cloud-ready | Use released service or API |
| `SUBMIT report` | Not allowed in cloud | N/A — redesign flow |
| `CALL TRANSACTION` | Not allowed | RAP action or OData call |
| `COMMIT WORK` / `ROLLBACK WORK` | RAP manages LUW | Let RAP framework handle |
| `WRITE` / `FORMAT` / list processing | Dynpro/list ABAP | Use RAP + Fiori |
| `AUTHORITY-CHECK` (classic) | Use RAP authorization | `get_global_authorizations` |
| `OPEN DATASET` | File I/O | Use attachments / BTP services |
| `MESSAGE` (classic) | Use RAP messages | `reported` table + `new_message_with_text` |
| `SYST-*` fields (most) | Partially restricted | Use `cl_abap_context_info` |
| `FIELD-SYMBOLS <*>` on DB tables | | Use typed field symbols |

---

## VDM (Virtual Data Model) — Use Instead of Direct Table Access

Always prefer **SAP VDM CDS views** over direct table reads:

```abap
" WRONG — Clean Core violation
SELECT matnr, maktx FROM mara
  INTO TABLE @DATA(products).

" CORRECT — use released VDM view
SELECT Product, ProductName FROM I_Product
  INTO TABLE @DATA(products).
```

### Key VDM Views by Domain

| Domain | Raw Table | Use VDM View Instead |
|--------|-----------|---------------------|
| Material / Product | `mara`, `makt` | `I_Product`, `I_ProductDescription` |
| Business Partner | `but000`, `adrc` | `I_BusinessPartner`, `I_BPContactToAddress` |
| Sales Order | `vbak`, `vbap` | `I_SalesOrder`, `I_SalesOrderItem` |
| Purchase Order | `ekko`, `ekpo` | `I_PurchaseOrder`, `I_PurchaseOrderItem` |
| Financial Document | `bkpf`, `bseg` | `I_JournalEntry`, `I_JournalEntryItem` |
| Customer | `kna1` | `I_Customer` |
| Vendor / Supplier | `lfa1` | `I_Supplier` |
| Plant | `t001w` | `I_Plant` |
| Currency | `tcurc` | `I_Currency` |
| Country | `t005` | `I_Country` |

---

## Extension Points — Clean Way to Extend SAP

### BAdI (Business Add-In) — Preferred Extension Method

```abap
" 1. Find the BAdI definition in ADT: se18 equivalent
"    Search for BAdI: Enhancement Spot → BAdI Definition

" 2. Create BAdI implementation
CLASS zcl_badi_my_impl DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_badi_interface.  " actual BAdI interface
ENDCLASS.

CLASS zcl_badi_my_impl IMPLEMENTATION.
  METHOD if_badi_interface~my_method.
    " your custom logic here
  ENDMETHOD.
ENDCLASS.

" 3. Register in Enhancement Implementation (ADT / SE19)
```

### RAP Business Object Extensions
Extend SAP standard RAP BOs without modification:

```abap
" Extension of standard BO (BDEF extension)
extension using interface ZI_MyExtension
  implementation in class zbp_ext_mybo unique;

extend behavior for I_StandardBO {
  field ( readonly ) ZMyCustomField;
  validation ZValidateMyField on save { create; update; }
}
```

### Key Extension Scenarios

| Scenario | Extension Method |
|----------|----------------|
| Add logic before/after save | BAdI on BO save event |
| Add custom fields to standard screen | RAP BO extension + UI annotation |
| Add custom validation | BAdI / RAP validation extension |
| Trigger external system | BAdI + outbound service call |
| Custom Fiori tile / app | New RAP BO (Z*) calling released APIs |

---

## ATC Clean Core Checks

### Standard ATC Check Variants for Clean Core

| Check Variant | Purpose |
|--------------|---------|
| `ABAP_CLOUD` | Checks all ABAP Cloud restrictions |
| `SAP_CLOUD_PLATFORM` | BTP-specific restrictions |
| `SLIN_BEHV` | Functional correctness checks |
| Custom variant | Add to your CI/CD pipeline |

### Running ATC via REST (SAP_COM_0748)
```json
POST /sap/bc/adt/atc/runs
{
  "maximumVerdicts": 100,
  "objectSets": [{
    "type": "multiPropertySet",
    "multiPropertySet": {
      "adtcore:objectProperties": [{
        "adtcore:name": "ZMY_PACKAGE",
        "adtcore:type": "DEVC/K"
      }]
    }
  }],
  "checkVariant": "ABAP_CLOUD"
}
```

### Common ATC Clean Core Findings and Fixes

| ATC Finding | Meaning | Fix |
|-------------|---------|-----|
| `USE_DDIC_ENTITY` | Reading SAP table directly | Replace with VDM CDS view |
| `CALL_NON_RELEASED_API` | Using unreleased class/FM | Find released alternative |
| `SLIN_BEHV_*` | Behavioral issue | Follow suggested refactor |
| `NO_AUTHORITY_CHECK` | Missing auth | Add to `get_global_authorizations` |
| `CLASSIC_EXCEPTIONS` | Old exception model | Use class-based exceptions |
| `COMMIT_IN_BADI` | COMMIT WORK in BAdI | Remove — framework handles LUW |

---

## Custom ATC Check for Clean Core (IF_ATC_CHECK)

Implement a custom check enforcing your project's clean core rules:

```abap
CLASS zcl_atc_clean_core_check DEFINITION
  PUBLIC INHERITING FROM cl_atc_check_base
  FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_atc_check.

  PRIVATE SECTION.
    METHODS check_for_direct_table_reads
      IMPORTING source TYPE string
      RETURNING VALUE(findings) TYPE if_atc_check=>findings_type.
ENDCLASS.

CLASS zcl_atc_clean_core_check IMPLEMENTATION.

  METHOD if_atc_check~run.
    " Get source code of object under check
    DATA(source) = me->get_source_code( ).

    " Check 1: direct reads on banned tables
    LOOP AT VALUE #(
      ( `MARA` ) ( `MAKT` ) ( `KNA1` ) ( `LFA1` )
      ( `VBAK` ) ( `VBAP` ) ( `EKKO` ) ( `EKPO` )
    ) INTO DATA(table).
      IF source CS |SELECT * FROM { table }| OR
         source CS |FROM { table } INTO|.
        APPEND VALUE #(
          severity    = if_atc_check=>severity-error
          kind        = if_atc_check=>kind-style
          text        = |Direct read on { table } — use VDM view instead|
          title       = 'Clean Core: Direct Table Access'
        ) TO findings.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
```

**Register:** ADT → ATC → Check Variant → Add `ZCL_ATC_CLEAN_CORE_CHECK`

---

## Clean Core Checklist — Before Every Code Review

```
GENERAL
  [ ] No changes to SAP standard objects
  [ ] No implicit/explicit enhancements on SAP source
  [ ] All extensions use official BAdI or RAP extension points

API USAGE
  [ ] All SAP APIs used are C1 released (check in ADT properties)
  [ ] No direct SELECT on SAP standard tables
  [ ] VDM views used for all SAP data reads
  [ ] No unreleased Function Modules called

ABAP CLOUD RESTRICTIONS
  [ ] No SUBMIT, CALL TRANSACTION, WRITE statements
  [ ] No COMMIT WORK / ROLLBACK WORK in handler methods
  [ ] No OPEN DATASET / file I/O
  [ ] Messages via reported table (not MESSAGE statement)
  [ ] Authority checks via get_global_authorizations (not AUTHORITY-CHECK)

ATC
  [ ] ABAP_CLOUD check variant passes with zero errors
  [ ] Custom clean core ATC check passes
  [ ] No SLIN_BEHV warnings

RAP SPECIFIC
  [ ] READ ENTITIES used instead of direct SELECT
  [ ] %tky used (not %key) when draft is active
  [ ] mapping for defined explicitly
  [ ] strict ( 2 ) in all new BDEFs
```

---

## Quick Reference — Released vs. Not Released

```abap
" RELEASED — safe to use in cloud ABAP
cl_abap_context_info=>get_user_technical_name( )   " current user
cl_system_uuid=>create_uuid_x16_static( )          " UUID generation
cl_abap_format=>get( )                             " number formatting
xco_cp_time=>moment( )                             " timestamps

" NOT released — avoid in cloud
sy-uname         " use cl_abap_context_info instead
sy-datum / sy-uzeit  " use cl_abap_context_info=>get_system_date/time
CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'        " use XCO library
CALL FUNCTION 'REUSE_ALV_*'                        " no ALV in cloud
```

---

## Best Practices

1. **Check release state first** — before using any SAP object, verify C1 in ADT
2. **VDM by default** — never write `FROM mara`, always look for `I_*` equivalent
3. **BAdI over enhancement** — if SAP provides a BAdI, always prefer it
4. **ATC in CI/CD** — run `ABAP_CLOUD` check variant on every PR via SAP_COM_0748
5. **Custom ATC** — encode project-specific rules (banned tables, naming) as custom checks
6. **Upgrade test** — clean core code survives SAP upgrades without rework
7. **Never COMMIT in BAdI** — the calling framework owns the LUW
8. **Use XCO library** — `xco_cp_*` classes provide cloud-ready utilities for common tasks
