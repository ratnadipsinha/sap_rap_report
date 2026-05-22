# SAP RAP BTP TRIAL — SUCCESSFUL DEPLOYMENT GUIDE

## Overview
Step-by-step working guide for deploying a SAP RAP List Report on BTP ABAP Trial.
Tested and verified on BTP ABAP Trial — AP21 region.

---

## SYSTEM DETAILS
- **BTP Host:** `a396c05d-a792-494b-a9f2-5b3f674def78.abap-web.ap21.hana.ondemand.com`
- **BAS URL:** `https://bae48832trial.ap21cf.trial.applicationstudio.cloud.sap`
- **Package:** `ZXX_REPORTS`
- **GitHub Repo:** `https://github.com/ratnadipsinha/SAP_RAP_REPORT.git`

---

## STEP 1 — ECLIPSE SETUP

### Install ADT Plugin
1. Eclipse → **Help → Install New Software**
2. Add URL: `https://tools.hana.ondemand.com/latest`
3. Select **ABAP Development Tools** → Install → Restart

### Install abapGit Plugin
1. **Help → Install New Software**
2. Add URL: `https://eclipse.abapgit.org/updatesite/`
3. Select **abapGit for ADT** → Install → Restart

### Connect to BTP System
1. **File → New → Other → ABAP → ABAP Project**
2. Select **SAP BTP, ABAP Environment**
3. Enter BTP host URL → login via browser SSO

---

## STEP 2 — CREATE PACKAGES IN ECLIPSE

1. Right-click project → **New → ABAP Package**
   - Name: `ZXX` → Description: `ZXX Root Package`
2. Right-click `ZXX` → **New → ABAP Package**
   - Name: `ZXX_REPORTS` → Description: `SAP RAP Sales Report Objects`

---

## STEP 3 — ABAPGIT CLONE FROM GITHUB

1. **Window → Show View → Other → abapGit Repositories**
2. Click **+** (Clone)
3. URL: `https://github.com/ratnadipsinha/SAP_RAP_REPORT.git`
4. Branch: `main`
5. Package: `ZXX_REPORTS`
6. Click **Finish**

### abapGit Pull Result
| Object | Type | Result |
|---|---|---|
| ZXX_SALESDATA | TABL | ✓ Success |
| ZXX_I_SALESREPORT | DDLS | ✓ Success |
| ZXX_C_SALESREPORT | DDLS | ✓ Success |
| ZXX_I_SALESREPORT | BDEF | ✗ Create manually |
| ZXX_UI_SALESREPORT_O4 | SRVD | ✗ Create manually |

---

## STEP 4 — ACTIVATE OBJECTS (EXACT ORDER)

1. `ZXX_SALESDATA` → Activate (`Ctrl+F3`)
2. `ZXX_I_SALESREPORT` → Activate
3. `ZXX_C_SALESREPORT` → Activate
4. `ZXX_UI_SALESREPORT_O4` Service Definition → Activate
5. `ZXX_UI_SALESREPORT_O4` Service Binding → Activate → **Publish**

---

## STEP 5 — CREATE BDEF MANUALLY

> abapGit cannot import BDEF — always create manually in Eclipse

1. Right-click `ZXX_REPORTS` → **New → Other → ABAP → Behavior Definition**
2. Root Entity: `ZXX_I_SalesReport`
3. Paste content:

```abap
managed;
strict ( 2 );

define behavior for ZXX_I_SalesReport
{
  mapping for zxx_salesdata
  {
    SalesOrder          = sales_order;
    SalesOrganization   = sales_org;
    CompanyCode         = company_code;
    DistributionChannel = dist_channel;
    CreationDate        = creation_date;
    OverallStatus       = status;
    Currency            = currency;
    OrderValueNet       = order_value;
    InvoiceValueNet     = invoice_value;
    InvoiceCount        = invoice_cnt;
    DeliveryCount       = delivery_cnt;
    FulfilmentPercent   = fulfil_pct;
    BillingPercent      = billing_pct;
  }
}
```

4. `Ctrl+S` → `Ctrl+F3`

---

## STEP 6 — CREATE SERVICE DEFINITION MANUALLY

> abapGit cannot import SRVD — always create manually in Eclipse

1. Right-click `ZXX_REPORTS` → **New → Other → ABAP → Service Definition**
2. Name: `ZXX_UI_SALESREPORT_O4`
3. Paste content:

```abap
@EndUserText.label: 'Sales Cycle Report - Service Definition'

define service ZXX_UI_SalesReport_O4 {
  expose ZXX_C_SalesReport as SalesReport;
}
```

4. `Ctrl+S` → `Ctrl+F3`

---

## STEP 7 — CREATE SERVICE BINDING

1. Right-click `ZXX_REPORTS` → **New → Other → ABAP → Service Binding**
2. Fill in:
   - Name: `ZXX_UI_SALESREPORT_O4`
   - Binding Type: `OData V4 - UI`
   - Service Definition: `ZXX_UI_SALESREPORT_O4`
3. Activate → **Publish**
4. Click **Preview** next to `SalesReport` entity → Fiori app opens

---

## STEP 8 — ADD TEST DATA

1. Right-click `ZXX_REPORTS` → **New → ABAP Class**
   - Name: `ZXX_CL_INSERT_TESTDATA`
2. Paste and run:

```abap
CLASS zxx_cl_insert_testdata DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zxx_cl_insert_testdata IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DELETE FROM zxx_salesdata.
    INSERT zxx_salesdata FROM TABLE @( VALUE #(
      ( sales_order = '1000000001' company_code = '1000' sales_org = 'S001' dist_channel = '10' creation_date = '20260101' status = 'C' currency = 'USD' order_value = '50000.00' invoice_value = '48000.00' invoice_cnt = 3 delivery_cnt = 2 fulfil_pct = '96.00' billing_pct = '96.00' )
      ( sales_order = '1000000002' company_code = '1000' sales_org = 'S001' dist_channel = '10' creation_date = '20260115' status = 'B' currency = 'USD' order_value = '30000.00' invoice_value = '25000.00' invoice_cnt = 2 delivery_cnt = 1 fulfil_pct = '83.00' billing_pct = '83.00' )
      ( sales_order = '1000000003' company_code = '1000' sales_org = 'S002' dist_channel = '20' creation_date = '20260201' status = 'C' currency = 'USD' order_value = '75000.00' invoice_value = '75000.00' invoice_cnt = 5 delivery_cnt = 3 fulfil_pct = '100.00' billing_pct = '100.00' )
      ( sales_order = '1000000004' company_code = '2000' sales_org = 'S002' dist_channel = '20' creation_date = '20260210' status = 'A' currency = 'EUR' order_value = '20000.00' invoice_value = '10000.00' invoice_cnt = 1 delivery_cnt = 1 fulfil_pct = '50.00' billing_pct = '50.00' )
      ( sales_order = '1000000005' company_code = '2000' sales_org = 'S003' dist_channel = '10' creation_date = '20260301' status = 'C' currency = 'EUR' order_value = '90000.00' invoice_value = '90000.00' invoice_cnt = 6 delivery_cnt = 4 fulfil_pct = '100.00' billing_pct = '100.00' )
    ) ).
    out->write( 'Test data inserted successfully!' ).
  ENDMETHOD.
ENDCLASS.
```

3. Right-click → **Run As → ABAP Application (Console)**

---

## WORKING CDS FILE DEFINITIONS

### ZXX_I_SalesReport (Interface View)
```abap
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Sales Cycle Report - Interface View'
@Analytics.dataCategory: #CUBE
@AbapCatalog.viewEnhancementCategory: [#NONE]

define view entity ZXX_I_SalesReport
  as select from zxx_salesdata
{
  key sales_order    as SalesOrder,
      sales_org      as SalesOrganization,
      company_code   as CompanyCode,
      dist_channel   as DistributionChannel,
      creation_date  as CreationDate,
      creation_date  as SalesOrderDate,
      status         as OverallStatus,
      currency       as Currency,
      company_code   as CompanyCodeName,
      sales_org      as SalesOrganizationName,
      dist_channel   as DistributionChannelName,
      order_value    as OrderValueNet,
      sales_order    as SalesOrderCount,
      invoice_value  as InvoiceValueNet,
      invoice_cnt    as InvoiceCount,
      delivery_cnt   as DeliveryCount,
      fulfil_pct     as FulfilmentPercent,
      billing_pct    as BillingPercent
}
```

### ZXX_C_SalesReport (Projection View)
```abap
@EndUserText.label: 'Sales Cycle Report - Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName:       'Sales Report',
  typeNamePlural: 'Sales Reports'
}

define view entity ZXX_C_SalesReport
  as projection on ZXX_I_SalesReport
{
  @UI.selectionField: [{ position: 10 }]
  @UI.lineItem: [{ position: 10, label: 'Sales Order' }]
  key SalesOrder,

  @UI.selectionField: [{ position: 20 }]
  @UI.lineItem: [{ position: 20, label: 'Company Code' }]
  CompanyCode,

  @UI.selectionField: [{ position: 30 }]
  @UI.lineItem: [{ position: 30, label: 'Sales Org' }]
  SalesOrganization,

  @UI.selectionField: [{ position: 40 }]
  @UI.lineItem: [{ position: 40, label: 'Dist Channel' }]
  DistributionChannel,

  @UI.lineItem: [{ position: 50, label: 'Creation Date' }]
  CreationDate,

  @UI.lineItem: [{ position: 60, label: 'Status' }]
  OverallStatus,

  @UI.lineItem: [{ position: 70, label: 'Order Value' }]
  OrderValueNet,

  @UI.lineItem: [{ position: 80, label: 'Invoice Value' }]
  InvoiceValueNet,

  @UI.lineItem: [{ position: 90, label: 'Fulfilment %' }]
  FulfilmentPercent,

  @UI.lineItem: [{ position: 100, label: 'Billing %' }]
  BillingPercent,

  Currency,
  SalesOrderDate,
  SalesOrderCount,
  InvoiceCount,
  DeliveryCount,
  CompanyCodeName,
  SalesOrganizationName,
  DistributionChannelName
}
```

---

## KEY LESSONS LEARNED

| Issue | Solution |
|---|---|
| BDEF won't import via abapGit | Always create manually in Eclipse |
| SRVD won't import via abapGit | Always create manually in Eclipse |
| `@Analytics.dimension` unknown | Remove — not available in trial |
| `@Analytics.measure` unknown | Remove — not available in trial |
| `@AbapCatalog.compiler.compareFilter` error | Remove — not for view entities |
| `@AbapCatalog.sqlViewAppendName` error | Remove — not for view entities |
| `provider contract analytical_query` fails | Use standard projection view |
| `@AccessControl.authorizationCheck: #INHERITED` | Use `#NOT_REQUIRED` |
| `define root view entity` on base view | Use `define view entity` |
| `abap.cuky` / `abap.curr` syntax error | Use `abap.char(5)` / `abap.dec(23,2)` |
| I_SalesOrder / I_BillingDocumentItem missing | Use custom table `ZXX_SALESDATA` |
| Transient view needs specific auth check | Use `#NOT_ALLOWED` |
| abapGit pull shows success but empty | Add `.abapgit.xml` to repo root |
| TABL as DDLS file fails | Use `.tabl.xml` with TABL serializer |
