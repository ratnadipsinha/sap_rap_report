# SAP RAP — COMPLETE DEPLOYMENT GUIDE
### From Claude Skills to Live Fiori App on BTP

> Tested and verified on SAP BTP ABAP Trial — AP21 region.

---

## SYSTEM REFERENCE

| Item | Value |
|---|---|
| BTP Host | `a396c05d-a792-494b-a9f2-5b3f674def78.abap-web.ap21.hana.ondemand.com` |
| BAS URL | `https://bae48832trial.ap21cf.trial.applicationstudio.cloud.sap` |
| GitHub Repo | `https://github.com/ratnadipsinha/SAP_RAP_REPORT.git` |
| Package | `ZXX_REPORTS` |
| OData Path | `/sap/opu/odata4/sap/zxx_ui_salesreport_o4/srvd/sap/zxx_ui_salesreport_o4/0001/` |
| Fiori Launchpad | `<BTP Host>/sap/bc/ui2/flp` |

---

---

# CHAPTER 1 — CLAUDE SKILLS SETUP

## What Are Skills
Skills are instruction files loaded into Claude Code before generating ABAP code.
They enforce naming conventions, BTP trial limitations, and RAP patterns.

## Skill Files (in `Skills/` folder)

| File | Purpose | When to Load |
|---|---|---|
| `SAP-NAMING-CONVENTION.md` | ZXX_ prefix rules | Always — load first |
| `SAP-FIORI-DESIGNER.md` | Floor plan decisions | New screen design |
| `SAP-RAP-DEVELOPER.md` | CDS / BDEF code generation | Writing ABAP objects |
| `SAP-CLEAN-CORE.md` | Compliance review | Before every deploy |
| `SAP-BTP-TRIAL-TEMPLATE.md` | BTP trial limitations + working patterns | Load before any code gen on trial |

## Mandatory Sequence for New Features

```
1. /sap-fiori-designer       → decide layout
2. /sap-naming-convention    → generate ZXX_ names
3. /sap-rap-developer        → generate CDS, BDEF, class
4. /sap-clean-core           → compliance check
```

## BTP Trial Key Limitations (from SAP-BTP-TRIAL-TEMPLATE skill)

| Not Available | Use Instead |
|---|---|
| `I_SalesOrder`, `I_BillingDocumentItem` | Custom table `ZXX_SALESDATA` |
| `@Analytics.dimension / .measure` | Remove — not in trial |
| `define root view entity` on base view | `define view entity` |
| `provider contract analytical_query` | Standard projection (no contract) |
| `@AccessControl.authorizationCheck: #INHERITED` | `#NOT_REQUIRED` |
| `abap.cuky` / `abap.curr` | `abap.char(5)` / `abap.dec(23,2)` |

---

---

# CHAPTER 2 — GITHUB REPOSITORY

## Repository Structure

```
SAP_RAP_REPORT/
├── .abapgit.xml                        ← required for abapGit pull to work
├── src/
│   ├── zxx_salesdata.tabl.xml          ← database table
│   ├── zxx_i_salesreport.ddls.asddls   ← interface CDS view (source)
│   ├── zxx_i_salesreport.ddls.xml      ← interface CDS view (metadata)
│   ├── zxx_c_salesreport.ddls.asddls   ← projection CDS view (source)
│   ├── zxx_c_salesreport.ddls.xml      ← projection CDS view (metadata)
│   ├── zxx_i_salesreport.bdef.asbdef   ← BDEF reference (create manually in Eclipse)
│   └── zxx_ui_salesreport_o4.srvd.srvdsrv  ← SRVD reference (create manually in Eclipse)
├── Skills/                             ← Claude skill files
├── docs/                               ← guides
└── project.config.yml                  ← central config
```

## Critical — .abapgit.xml (must exist at repo root)

```xml
<?xml version="1.0" encoding="utf-8"?>
<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
    <DATA>
      <MASTER_LANGUAGE>E</MASTER_LANGUAGE>
      <STARTING_FOLDER>/src/</STARTING_FOLDER>
      <FOLDER_LOGIC>PREFIX</FOLDER_LOGIC>
    </DATA>
  </asx:values>
</asx:abap>
```

> Without this file, abapGit pull succeeds but imports nothing.

## abapGit File Naming Rules

| Object | Source File | Metadata File |
|---|---|---|
| CDS View | `name.ddls.asddls` | `name.ddls.xml` |
| Database Table | *(none)* | `name.tabl.xml` |
| Behavior Definition | `name.bdef.asbdef` | `name.bdef.xml` |
| Service Definition | `name.srvd.srvdsrv` | `name.srvd.xml` |
| ABAP Class | `name.clas.abap` | `name.clas.xml` |

> SRVD extension is `.srvdsrv` — NOT `.asrvd`

---

---

# CHAPTER 3 — GITHUB PERSONAL ACCESS TOKEN

> GitHub does not accept passwords. A Personal Access Token (PAT) is required.

## Create the Token

1. Go to **github.com** → sign in
2. Profile picture → **Settings**
3. Left sidebar (bottom) → **Developer settings**
4. **Personal access tokens → Tokens (classic)**
5. **Generate new token (classic)**
   - Note: `abapGit Eclipse`
   - Expiration: `90 days`
   - Scope: tick **`repo`** (top checkbox)
6. Click **Generate token** → **copy immediately** (starts with `ghp_...`)

> You will not see the token again after leaving the page.

## Use Token in Eclipse abapGit

When prompted for credentials:
- **Username:** `ratnadipsinha`
- **Password:** paste the `ghp_...` token (not your GitHub password)

## Clear Saved Credentials (if failing)

1. Eclipse → **Window → Preferences → General → Security → Secure Storage**
2. Find the GitHub entry → **Delete**
3. Retry the abapGit operation — it will re-prompt

---

---

# CHAPTER 4 — ECLIPSE SETUP

## Install ADT Plugin

1. Eclipse → **Help → Install New Software**
2. Add URL: `https://tools.hana.ondemand.com/latest`
3. Select **ABAP Development Tools** → Install → Restart

## Install abapGit Plugin

1. **Help → Install New Software**
2. Add URL: `https://eclipse.abapgit.org/updatesite/`
3. Select **abapGit for ADT** → Install → Restart

## Connect to BTP System

1. **File → New → Other → ABAP → ABAP Project**
2. Select **SAP BTP, ABAP Environment**
3. Enter BTP host URL → login via browser SSO

---

---

# CHAPTER 5 — ABAP PACKAGES

1. Right-click project → **New → ABAP Package**
   - Name: `ZXX` | Description: `ZXX Root Package`
2. Right-click `ZXX` → **New → ABAP Package**
   - Name: `ZXX_REPORTS` | Description: `SAP RAP Sales Report Objects`

---

---

# CHAPTER 6 — ABAPGIT PULL FROM GITHUB

## Clone the Repository

1. Eclipse → **Window → Show View → Other → abapGit Repositories**
2. Click **+** (Clone)
3. URL: `https://github.com/ratnadipsinha/SAP_RAP_REPORT.git`
4. Branch: `main`
5. Package: `ZXX_REPORTS`
6. Click **Finish**
7. Enter credentials: username + `ghp_...` token

## Expected Pull Results

| Object | Type | Result |
|---|---|---|
| ZXX_SALESDATA | TABL | Imports successfully |
| ZXX_I_SALESREPORT | DDLS | Imports successfully |
| ZXX_C_SALESREPORT | DDLS | Imports successfully |
| ZXX_I_SALESREPORT | BDEF | Create manually — see Chapter 7 |
| ZXX_UI_SALESREPORT_O4 | SRVD | Create manually — see Chapter 8 |

---

---

# CHAPTER 7 — CREATE BDEF MANUALLY

> abapGit cannot reliably import BDEF — always create manually in Eclipse.

1. Right-click `ZXX_REPORTS` → **New → Other → ABAP → Behavior Definition**
2. Root Entity: `ZXX_I_SalesReport`
3. Paste this content:

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

4. `Ctrl+S` → `Ctrl+F3` (activate)

---

---

# CHAPTER 8 — CREATE SERVICE DEFINITION MANUALLY

> abapGit cannot reliably import SRVD — always create manually in Eclipse.

1. Right-click `ZXX_REPORTS` → **New → Other → ABAP → Service Definition**
2. Name: `ZXX_UI_SALESREPORT_O4`
3. Paste this content:

```abap
@EndUserText.label: 'Sales Cycle Report - Service Definition'

define service ZXX_UI_SalesReport_O4 {
  expose ZXX_C_SalesReport as SalesReport;
}
```

4. `Ctrl+S` → `Ctrl+F3` (activate)

---

---

# CHAPTER 9 — CREATE SERVICE BINDING

1. Right-click `ZXX_REPORTS` → **New → Other → ABAP → Service Binding**
2. Fill in:
   - Name: `ZXX_UI_SALESREPORT_O4`
   - Binding Type: `OData V4 - UI`
   - Service Definition: `ZXX_UI_SALESREPORT_O4`
3. `Ctrl+S` → **Activate** → **Publish**
4. Click **Preview** next to `SalesReport` → Fiori List Report opens in browser

---

---

# CHAPTER 10 — ACTIVATE OBJECTS (EXACT ORDER)

> Never activate out of order — dependency errors will occur.

```
1. ZXX_SALESDATA          (table)
2. ZXX_I_SALESREPORT      (interface CDS view)
3. ZXX_C_SALESREPORT      (projection CDS view)
4. ZXX_UI_SALESREPORT_O4  (service definition)
5. ZXX_UI_SALESREPORT_O4  (service binding) → Activate → Publish
```

Activate each with `Ctrl+F3`.

---

---

# CHAPTER 11 — ADD TEST DATA

1. Right-click `ZXX_REPORTS` → **New → ABAP Class**
   - Name: `ZXX_CL_INSERT_TESTDATA`
2. Paste this content:

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

3. `Ctrl+F3` (activate) → Right-click → **Run As → ABAP Application (Console)**

---

---

# CHAPTER 12 — ODATA SERVICE

| | URL |
|---|---|
| Service root | `https://<BTP Host>/sap/opu/odata4/sap/zxx_ui_salesreport_o4/srvd/sap/zxx_ui_salesreport_o4/0001/` |
| Entity data | `<service root>/SalesReport` |
| Metadata | `<service root>/$metadata` |

**Full service root:**
```
https://a396c05d-a792-494b-a9f2-5b3f674def78.abap-web.ap21.hana.ondemand.com/sap/opu/odata4/sap/zxx_ui_salesreport_o4/srvd/sap/zxx_ui_salesreport_o4/0001/
```

---

---

# CHAPTER 13 — FIORI APP IN BAS

## Step 1 — Login to Cloud Foundry

Open BAS → **Terminal → New Terminal** (`Ctrl+backtick`)

```bash
cf login -a https://api.cf.ap21.hana.ondemand.com
```

Enter your BTP email and password. Select org/space when prompted.

## Step 2 — Generate Fiori App

1. **View → Command Palette** (`Ctrl+Shift+P`)
2. Type: `Fiori: Open Application Generator` → select
3. Fill in:

| Field | Value |
|---|---|
| Template | List Report Page |
| Data Source | Connect to a System |
| System | Cloud Foundry ABAP environment on SAP BTP |
| ABAP Environment | select your BTP system |
| Service | `ZXX_UI_SALESREPORT_O4` |
| Main entity | `SalesReport` |
| Module name | `salesreport` |
| App title | `Sales Cycle Report` |
| Namespace | `com.zxx` |

4. Click **Finish**

## Step 3 — Run the App

```bash
cd project1
npx ui5 serve --open index.html
```

If dependency errors occur first:
```bash
npm install --legacy-peer-deps
npx ui5 serve --open index.html
```

---

---

# CHAPTER 14 — DEPLOY TO FIORI LAUNCHPAD

## Step 1 — Deploy App to ABAP System

In BAS terminal:
```bash
npm run deploy
```

When prompted:
- System URL: `https://a396c05d-a792-494b-a9f2-5b3f674def78.abap-web.ap21.hana.ondemand.com`
- Package: `ZXX_REPORTS`
- BSP App Name: `ZXX_SALESREPORT_UI`

## Step 2 — Create IAM App in Eclipse

1. Open **`ZXX_UI_SALESREPORT_O4`** Service Binding
2. Click **Create IAM App**
   - Name: `ZXX_SALESREPORT_IAM`
   - App Type: `EXT-UI`
3. In IAM App → **Services** tab → add `ZXX_UI_SALESREPORT_O4`
4. **Publish Locally**

## Step 3 — Assign Business Role

1. BTP Cockpit → subaccount → **Security → Role Collections**
2. Create: `ZXX_SALES_REPORT_USER`
3. Add IAM app role → assign to your user

## Step 4 — Open Fiori Launchpad

```
https://a396c05d-a792-494b-a9f2-5b3f674def78.abap-web.ap21.hana.ondemand.com/sap/bc/ui2/flp
```

---

---

# APPENDIX — LESSONS LEARNED

| Error | Fix |
|---|---|
| abapGit pull succeeds but nothing imported | Add `.abapgit.xml` to repo root |
| BDEF won't import via abapGit | Always create manually in Eclipse |
| SRVD won't import via abapGit | Always create manually in Eclipse |
| SRVD file not found by abapGit | Extension must be `.srvdsrv` not `.asrvd` |
| `@Analytics.dimension` unknown | Remove — not available in trial |
| `@Analytics.measure` unknown | Remove — not available in trial |
| `@AbapCatalog.compiler.compareFilter` error | Remove — not for view entities |
| `provider contract analytical_query` fails | Use standard projection, no contract |
| `@AccessControl.authorizationCheck: #INHERITED` | Use `#NOT_REQUIRED` |
| `define root view entity` on base view | Use `define view entity` |
| `abap.cuky` / `abap.curr` syntax error | Use `abap.char(5)` / `abap.dec(23,2)` |
| I_SalesOrder / VDM views missing | Use custom table `ZXX_SALESDATA` |
| GitHub password rejected in abapGit | Use Personal Access Token (`ghp_...`) |
| BAS "Discovering ABAP Environments failed" | Run `cf login` in BAS terminal first |
| `npm start` / `fiori run` fails silently | Use `npx ui5 serve --open index.html` |
| npm ERESOLVE dependency conflict | Run `npm install --legacy-peer-deps` |
