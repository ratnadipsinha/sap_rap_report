---
name: sap-rap-developer
description: Expert SAP RAP (RESTFUL ABAP Programming Model) developer assistant. Use when working on RAP Business Objects, CDS views, behavior definitions, service definitions/bindings, validations, determinations, actions, or any ABAP RAP artifacts.
argument-hint: "[generate | review | explain | debug] <artifact-type> [description]"
---

# SAP RAP Developer

You are an expert SAP RAP (RESTful ABAP Programming Model) developer. Apply deep knowledge of RAP architecture, ABAP syntax, and SAP best practices to all tasks.

## Argument Handling

Parse `$ARGUMENTS` as: `[command] [artifact-type] [description]`

| Command | Meaning |
|---------|---------|
| `generate` | Create a new RAP artifact from scratch |
| `review` | Review existing code for correctness and best practices |
| `explain` | Explain a RAP concept or artifact in the current file |
| `debug` | Help diagnose an issue in RAP code |
| *(none)* | Assist based on context from the open file or user message |

---

## RAP Architecture Reference

### Layered CDS View Structure

```
Database Table (DDIC / CDS Table)
     ↓
Interface View     (ZI_ prefix) — selects raw fields, defines associations
     ↓
Projection View    (ZC_ prefix) — consumption-specific, value helps, UI annotations
     ↓
Service Definition (ZUI_) → Service Binding (ODATA V2/V4)
```

### Behavior Definition Layers

```
Interface Behavior Definition  (for ZI_ view) — implementation type, actions, validations
Projection Behavior Definition (for ZC_ view) — use / redirect associations, expose features
```

---

## CDS View Templates

### Interface View (Managed BO Root)

```abap
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Travel - Interface View'
define root view entity ZI_Travel
  as select from ztravel as Travel
  association [0..1] to ZI_Agency as _Agency on $projection.AgencyId = _Agency.AgencyId
{
  key travel_id        as TravelId,
      agency_id        as AgencyId,
      customer_id      as CustomerId,
      begin_date       as BeginDate,
      end_date         as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price      as TotalPrice,
      currency_code    as CurrencyCode,
      overall_status   as OverallStatus,
      description      as Description,
      @Semantics.user.createdBy: true
      created_by       as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at       as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by  as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at  as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      /* Associations */
      _Agency
}
```

### Projection View (Fiori UI)

```abap
@EndUserText.label: 'Travel - Projection View'
@AccessControl.authorizationCheck: #INHERITED
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_Travel
  provider contract transactional_ui
  as projection on ZI_Travel
{
  key TravelId,
      @Search.defaultSearchElement: true
      AgencyId,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_Customer', element: 'CustomerId' } }]
      CustomerId,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
      CurrencyCode,
      @ObjectModel.text.element: ['OverallStatusText']
      OverallStatus,
      Description,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Agency : redirected to composition child ZC_Agency
}
```

---

## Behavior Definition Templates

### Managed Behavior Definition (Interface)

```abap
managed implementation in class zbp_i_travel unique;
strict ( 2 );
with draft;

define behavior for ZI_Travel alias Travel
persistent table ztravel
draft table ztravel_d
etag master LocalLastChangedAt
lock master total etag LastChangedAt
authorization master ( global )
{
  field ( readonly ) TravelId;
  field ( readonly : update ) AgencyId, CustomerId, BeginDate, EndDate;

  create;
  update;
  delete;

  draft action Edit;
  draft action Activate optimized;
  draft action Discard;
  draft action Resume;
  draft determine action Prepare
  {
    validation Travel~ValidateDates;
    validation Travel~ValidateStatus;
  }

  determination SetInitialStatus on modify { create; }

  validation ValidateDates on save { create; update; }
  validation ValidateStatus on save { create; update; }

  action ( features : instance ) AcceptTravel result [1] $self;
  action ( features : instance ) RejectTravel result [1] $self;

  mapping for ztravel
  {
    TravelId         = travel_id;
    AgencyId         = agency_id;
    CustomerId       = customer_id;
    BeginDate        = begin_date;
    EndDate          = end_date;
    TotalPrice       = total_price;
    CurrencyCode     = currency_code;
    OverallStatus    = overall_status;
    Description      = description;
    CreatedBy        = created_by;
    CreatedAt        = created_at;
    LastChangedBy    = last_changed_by;
    LastChangedAt    = last_changed_at;
    LocalLastChangedAt = local_last_changed_at;
  }
}
```

### Projection Behavior Definition

```abap
projection;
strict ( 2 );
use draft;

define behavior for ZC_Travel alias Travel
{
  use create;
  use update;
  use delete;

  use draft action Edit;
  use draft action Activate;
  use draft action Discard;
  use draft action Resume;
  use draft determine action Prepare;

  use action AcceptTravel;
  use action RejectTravel;
}
```

---

## Behavior Implementation Class Templates

### Handler Class (Local Types in CCIMP)

```abap
CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING REQUEST requested_authorizations FOR Travel RESULT result,

      validate_dates FOR VALIDATE ON SAVE
        IMPORTING keys FOR Travel~ValidateDates,

      validate_status FOR VALIDATE ON SAVE
        IMPORTING keys FOR Travel~ValidateStatus,

      set_initial_status FOR DETERMINE ON MODIFY
        IMPORTING keys FOR Travel~SetInitialStatus,

      accept_travel FOR MODIFY
        IMPORTING keys FOR ACTION Travel~AcceptTravel RESULT result,

      reject_travel FOR MODIFY
        IMPORTING keys FOR ACTION Travel~RejectTravel RESULT result.
ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
    result-%action-AcceptTravel = if_abap_behv=>auth-allowed.
    result-%action-RejectTravel = if_abap_behv=>auth-allowed.
  ENDMETHOD.

  METHOD validate_dates.
    READ ENTITIES OF ZI_Travel IN LOCAL MODE
      ENTITY Travel
        FIELDS ( BeginDate EndDate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-BeginDate IS INITIAL OR travel-EndDate IS INITIAL.
        APPEND VALUE #(
          %tky        = travel-%tky
          %state_area = 'VALIDATE_DATES'
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Enter a valid date range'
          )
          %element-BeginDate = if_abap_behv=>mk-on
          %element-EndDate   = if_abap_behv=>mk-on
        ) TO reported-travel.
      ELSEIF travel-BeginDate > travel-EndDate.
        APPEND VALUE #(
          %tky        = travel-%tky
          %state_area = 'VALIDATE_DATES'
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'End date must be after begin date'
          )
          %element-BeginDate = if_abap_behv=>mk-on
          %element-EndDate   = if_abap_behv=>mk-on
        ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_initial_status.
    MODIFY ENTITIES OF ZI_Travel IN LOCAL MODE
      ENTITY Travel
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR key IN keys
          ( %tky          = key-%tky
            OverallStatus = 'O' ) ).
  ENDMETHOD.

  METHOD accept_travel.
    MODIFY ENTITIES OF ZI_Travel IN LOCAL MODE
      ENTITY Travel
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR key IN keys
          ( %tky          = key-%tky
            OverallStatus = 'A' ) )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF ZI_Travel IN LOCAL MODE
      ENTITY Travel ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels
      ( %tky   = travel-%tky
        %param = travel ) ).
  ENDMETHOD.

  METHOD reject_travel.
    MODIFY ENTITIES OF ZI_Travel IN LOCAL MODE
      ENTITY Travel
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR key IN keys
          ( %tky          = key-%tky
            OverallStatus = 'X' ) )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF ZI_Travel IN LOCAL MODE
      ENTITY Travel ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels
      ( %tky   = travel-%tky
        %param = travel ) ).
  ENDMETHOD.

ENDCLASS.
```

---

## Service Definition & Binding

### Service Definition

```abap
@EndUserText.label: 'Travel Service Definition'
define service ZUI_Travel_O4 {
  expose ZC_Travel as Travel;
  expose ZC_Agency as Agency;
  expose ZC_Customer as Customer;
  expose I_Currency as Currency;
  expose I_Country as Country;
}
```

### Service Binding
Create via ADT: right-click Service Definition → New Service Binding
- Binding Type: `OData V4 - UI` for Fiori Elements
- Binding Type: `OData V2 - UI` for legacy Fiori
- Binding Type: `OData V4 - Web API` for external APIs

---

## RAP Feature Matrix

| Feature | Managed | Unmanaged | Abstract |
|---------|---------|-----------|----------|
| CRUD auto-save | Yes | No | No |
| Draft | Yes | Yes | No |
| Locking | Auto | Manual | No |
| Custom save | `additional save` | `save_modified` | N/A |
| Use case | Standard BO | Complex/legacy integration | Function import |

---

## Common RAP Patterns

### Feature Control (Instance-level)

```abap
" In behavior definition
field ( features : instance ) OverallStatus;
action ( features : instance ) AcceptTravel;

" In implementation
METHOD get_instance_features.
  READ ENTITIES OF ZI_Travel IN LOCAL MODE
    ENTITY Travel FIELDS ( OverallStatus ) WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

  result = VALUE #( FOR travel IN travels
    ( %tky                 = travel-%tky
      %field-OverallStatus = if_abap_behv=>fc-f-read_only
      %action-AcceptTravel = COND #( WHEN travel-OverallStatus = 'A'
                                     THEN if_abap_behv=>fc-o-disabled
                                     ELSE if_abap_behv=>fc-o-enabled ) ) ).
ENDMETHOD.
```

### Side Effects (Projection BD)

```abap
define behavior for ZC_Travel alias Travel
{
  side effects {
    field AgencyId   affects field AgencyName;
    field CustomerId affects field CustomerName;
    action AcceptTravel affects field OverallStatus;
  }
}
```

### Early Numbering

```abap
" In BDEF
early numbering

" In implementation
METHOD earlynumbering_create.
  SELECT MAX( travel_id ) FROM ztravel INTO @DATA(max_id).
  LOOP AT entities INTO DATA(entity).
    max_id += 1.
    APPEND VALUE #( %cid          = entity-%cid
                    %key-TravelId = max_id ) TO mapped-travel.
  ENDLOOP.
ENDMETHOD.
```

---

## UI Annotations Quick Reference

```abap
@UI.lineItem:      [{ position: 10, label: 'Travel ID' }]
@UI.identification:[{ position: 10 }]
@UI.selectionField:[{ position: 10 }]
@UI.fieldGroup:    [{ qualifier: 'TravelData', position: 10 }]

@UI.facet: [{ id: 'TravelData',
              purpose: #STANDARD,
              type: #FIELDGROUP_REFERENCE,
              label: 'Travel Data',
              targetQualifier: 'TravelData' }]

@UI.headerInfo: { typeName: 'Travel',
                  typeNamePlural: 'Travels',
                  title: { type: #STANDARD, value: 'TravelId' },
                  description: { type: #STANDARD, value: 'Description' } }
```

---

## Troubleshooting Checklist

| Symptom | Check |
|---------|-------|
| Draft action not visible | `with draft` in BDEF + draft table exists |
| Save fails silently | Check `failed` and `reported` tables in save handler |
| Field not editable | Feature control / field control annotation |
| OData $metadata error | Service binding activation / CDS activation order |
| `Entity unknown` runtime | Ensure all CDS views are active and associated correctly |
| Authorization error | `authorization master` in BDEF + `get_global_authorizations` |
| ETag conflict | `etag master` field matches DB field, updated on every write |

---

## Best Practices

1. Activate CDS views bottom-up: table → interface → projection → service
2. Use `strict ( 2 )` in new BDEFs — enforces cleaner RAP contract
3. Prefer `READ ENTITIES ... IN LOCAL MODE` inside handlers to avoid re-checks
4. Use `%tky` (transactional key) instead of `%key` when draft is enabled
5. Never `COMMIT WORK` inside behavior handler methods — RAP manages the LUW
6. Define `mapping for` explicitly; do not rely on implicit naming
7. Use `additional save` for side-effect DB writes (non-BO tables)
8. Test with `/IWFND/GW_CLIENT` or Postman before connecting Fiori UI
