# SAP BTP TRIAL — ABAP RAP TEMPLATE
## Invoke: `/sap-btp-trial-template`

Defines the exact working file formats and patterns for SAP BTP ABAP Trial.
Use this BEFORE generating any code to avoid abapGit pull errors.

---

## BTP TRIAL LIMITATIONS

| Not Available | Use Instead |
|---|---|
| `I_SalesOrder`, `I_BillingDocumentItem` etc. | Custom table `ZXX_SALESDATA` |
| `@Analytics.dimension` | Remove — not recognised in trial |
| `@Analytics.measure` | Remove — not recognised in trial |
| `@AbapCatalog.compiler.compareFilter` | Remove — not allowed in view entities |
| `@AbapCatalog.sqlViewAppendName` | Remove — not allowed in view entities |
| `provider contract analytical_query` | Remove — not supported in OData V4 UI binding |
| `@AccessControl.authorizationCheck: #INHERITED` | Use `#NOT_REQUIRED` |
| `define root view entity` on base view | Use `define view entity` |

---

## ABAPGIT FILE NAMING — MANDATORY

| Object Type | Source File | Metadata File |
|---|---|---|
| CDS View (DDLS) | `name.ddls.asddls` | `name.ddls.xml` |
| Database Table (TABL) | none | `name.tabl.xml` |
| Behavior Definition (BDEF) | `name.bdef.asbdef` | `name.bdef.xml` |
| Service Definition (SRVD) | `name.srvd.srvdsrv` | `name.srvd.xml` |
| ABAP Class | `name.clas.abap` | `name.clas.xml` |

> **Critical:** SRVD extension is `.srvdsrv` NOT `.asrvd`

---

## ABAPGIT XML FORMATS — EXACT WORKING FORMATS

### CDS View (DDLS)
```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_DDLS" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DDLS>
    <DDLNAME>ZXX_OBJECT_NAME</DDLNAME>
    <DDLANGUAGE>E</DDLANGUAGE>
    <DDTEXT>Description here</DDTEXT>
   </DDLS>
  </asx:values>
 </asx:abap>
</abapGit>
```

### Database Table (TABL)
```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_TABL" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <DD02V>
    <TABNAME>ZXX_TABLE_NAME</TABNAME>
    <DDLANGUAGE>E</DDLANGUAGE>
    <TABCLASS>TRANSP</TABCLASS>
    <CLIDEP>X</CLIDEP>
    <DDTEXT>Table description</DDTEXT>
    <CONTFLAG>A</CONTFLAG>
   </DD02V>
   <DD09L>
    <TABNAME>ZXX_TABLE_NAME</TABNAME>
    <AS4LOCAL>A</AS4LOCAL>
    <TABKAT>0</TABKAT>
    <TABART>APPL0</TABART>
    <BUFALLOW>N</BUFALLOW>
   </DD09L>
   <DD03P_TABLE>
    <!-- field definitions here — see zxx_salesdata.tabl.xml as reference -->
   </DD03P_TABLE>
  </asx:values>
 </asx:abap>
</abapGit>
```

### BDEF + SRVD
> **Do NOT hand-write XML for BDEF and SRVD.**
> Always push from Eclipse via abapGit → GitHub gets correct XML automatically.
> Never create BDEF/SRVD XML manually — format is version-specific.

---

## WORKING CDS PATTERNS FOR BTP TRIAL

### Interface View (CUBE)
```abap
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Description'
@Analytics.dataCategory: #CUBE
@AbapCatalog.viewEnhancementCategory: [#NONE]

define view entity ZXX_I_EntityName        -- NO "root" keyword
  as select from zxx_custom_table
{
  key field1  as Field1,
      field2  as Field2,
      ...
}
```

### Projection View (List Report)
```abap
@EndUserText.label: 'Description'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName: 'Entity',
  typeNamePlural: 'Entities'
}

define view entity ZXX_C_EntityName        -- NO "root", NO "transient"
  as projection on ZXX_I_EntityName        -- NO provider contract
{
  @UI.selectionField: [{ position: 10 }]
  @UI.lineItem: [{ position: 10, label: 'Label' }]
  key Field1,                              -- explicit "key" required
      Field2,
      ...
}
```

### Service Definition
```abap
@EndUserText.label: 'Service Definition'

define service ZXX_UI_EntityName_O4 {
  expose ZXX_C_EntityName as EntityName;
}
```

---

## OBJECT ACTIVATION ORDER — MANDATORY

```
1. Database Table (ZXX_*DATA)
2. Interface CDS View (ZXX_I_*)
3. Projection CDS View (ZXX_C_*)
4. Service Definition (ZXX_UI_*_O4)
5. Service Binding (ZXX_UI_*_O4) → Activate → Publish
```

Never activate out of order — dependency errors will occur.

---

## DATABASE TABLE FIELD TYPES — BTP SAFE TYPES

| Use | Avoid |
|---|---|
| `abap.char(n)` | `abap.cuky` |
| `abap.dec(23,2)` | `abap.curr(16,2)` |
| `abap.int4` | domain-based types |
| `abap.dats` | |
| `abap.clnt` | |

---

## TEST DATA CLASS TEMPLATE

```abap
CLASS zxx_cl_insert_testdata DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zxx_cl_insert_testdata IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DELETE FROM zxx_salesdata.
    INSERT zxx_salesdata FROM TABLE @( VALUE #(
      ( sales_order = '1000000001' company_code = '1000' ... )
    ) ).
    out->write( 'Done!' ).
  ENDMETHOD.
ENDCLASS.
```

Run via: **Right-click → Run As → ABAP Application (Console)**

---

## ABAPGIT PUSH FIRST RULE

> After creating/fixing objects manually in Eclipse:
> **Always Push from Eclipse abapGit → GitHub FIRST**
> before pulling in a new system.
> This ensures GitHub always has the correct serialised XML.
