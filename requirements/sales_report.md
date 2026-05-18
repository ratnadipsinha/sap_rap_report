# Sales Report — Business Requirement

## Overview

| Field | Details |
|-------|---------|
| **Requirement ID** | REQ-001 |
| **Module** | Sales (SD) |
| **Type** | RAP Analytical Report / Fiori App |
| **Floor Plan** | Analytical List Page (ALP) |
| **Priority** | High |
| **Status** | Draft |

---

## Business Objective

Provide sales managers and controllers with a **single analytical view** of the complete sales cycle — from Sales Order through Delivery to Invoice — across company codes and sales organisations. The report must allow quick comparison of business performance across sales organisations within the same company code using both tabular and chart views.

---

## 1. Selection Screen (Filter Bar)

Users must be able to filter the report using the following input parameters:

| Filter Field | Label | Type | Mandatory | Notes |
|-------------|-------|------|-----------|-------|
| CompanyCode | Company Code | Input + Value Help | Yes | Multi-select |
| SalesOrganization | Sales Org | Input + Value Help | No | Multi-select |
| DistributionChannel | Distribution Channel | Input + Value Help | No | Multi-select |
| CreationDateFrom | Date of Creation (From) | Date Picker | Yes | Default: first day of current month |
| CreationDateTo | Date of Creation (To) | Date Picker | Yes | Default: today |

**Behaviour:**
- All filters apply simultaneously across the summary table and the chart
- Changing any filter refreshes both the table and the chart without page reload
- Variant management enabled — users can save and reload filter combinations

---

## 2. Summary Table — Sales Cycle Overview

Display a grouped summary of the complete sales cycle: **Sales Order to Delivery to Invoice**

### Grouping Hierarchy

```
Level 1 (Primary)   — Company Code
Level 2 (Secondary) — Sales Organisation
Level 3 (Detail)    — Distribution Channel
```

### Columns Required

| Column | Description | Source |
|--------|-------------|--------|
| Company Code | Company code | I_SalesOrder |
| Sales Organisation | Sales org code + name | I_SalesOrder |
| Distribution Channel | Distribution channel | I_SalesOrder |
| No. of Sales Orders | Count of sales orders | I_SalesOrder |
| Order Value (Net) | Sum of net order value | I_SalesOrderItem |
| No. of Deliveries | Count of deliveries | I_DeliveryDocument |
| Delivered Quantity | Total delivered qty | I_DeliveryDocumentItem |
| No. of Invoices | Count of billing documents | I_BillingDocument |
| Invoice Value (Net) | Sum of net invoice value | I_BillingDocumentItem |
| Currency | Currency code | I_SalesOrder |
| Fulfilment % | Delivered Qty / Ordered Qty x 100 | Calculated |
| Billing % | Invoice Value / Order Value x 100 | Calculated |

### Table Behaviour
- Rows grouped and collapsible at Company Code and Sales Org level
- Subtotals shown at each group level (Order Value, Invoice Value)
- Grand total row at bottom
- Sort by Invoice Value descending by default
- Export to Excel available in table toolbar

---

## 3. Analytical Chart View — Invoice Value by Sales Org

Display **two charts** below the summary table:

### Chart 1 — Pie Chart: Invoice Value by Sales Org
- Type: Donut / Pie chart
- Dimension: Sales Organisation
- Measure: Invoice Value (Net)
- Purpose: Show the share of total invoiced business per sales org
- Clicking a pie segment filters the summary table to that sales org

### Chart 2 — Bar Chart: Sales Org Comparison within Company Code
- Type: Grouped Bar chart
- X-axis: Sales Organisation
- Y-axis: Value (Net)
- Series: Order Value vs Invoice Value (side by side)
- Group by: Company Code (separate bar groups per company)
- Purpose: Compare business performance across sales orgs in the same company code
- Clicking a bar filters the summary table accordingly

### Page Layout

```
+--------------------------------------------------------------+
|  FILTER BAR: Company Code | Sales Org | Dist Channel | Date  |
+----------------------------+---------------------------------+
|  KPI HEADER                |                                 |
|  Total Orders: 1,240       |  Donut Chart                    |
|  Total Invoice: 4.2M       |  Invoice Value by Sales Org     |
|  Fulfilment: 87%           |                                 |
+----------------------------+---------------------------------+
|  Grouped Bar Chart — Order Value vs Invoice Value by Sales Org|
|  grouped per Company Code                                     |
+--------------------------------------------------------------+
|  SUMMARY TABLE                                               |
|  Company Code > Sales Org > Distribution Channel             |
|  (collapsible rows, subtotals, grand total)                  |
+--------------------------------------------------------------+
```

---

## 4. KPI Header

Show the following KPI cards at the top of the page:

| KPI | Formula | Criticality |
|-----|---------|-------------|
| Total Sales Orders | Count of orders in selection | Neutral |
| Total Order Value | Sum of net order value | Neutral |
| Total Invoice Value | Sum of net invoice value | Green if greater than 80% of order value |
| Overall Fulfilment % | Delivered Qty / Ordered Qty x 100 | Red below 70%, Yellow 70-90%, Green above 90% |
| Overall Billing % | Invoice Value / Order Value x 100 | Red below 70%, Yellow 70-90%, Green above 90% |

---

## 5. Data Sources — VDM Views (Clean Core)

All data must be read via SAP released VDM CDS views only. No direct table access.

| Data | VDM View | Key Join Field |
|------|----------|---------------|
| Sales Order header | I_SalesOrder | SalesOrder |
| Sales Order item | I_SalesOrderItem | SalesOrder, SalesOrderItem |
| Delivery header | I_DeliveryDocument | DeliveryDocument |
| Delivery item | I_DeliveryDocumentItem | DeliveryDocument, DeliveryDocumentItem |
| Billing / Invoice header | I_BillingDocument | BillingDocument |
| Billing / Invoice item | I_BillingDocumentItem | BillingDocument, BillingDocumentItem |
| Sales Organisation | I_SalesOrganization | SalesOrganization |
| Company Code | I_CompanyCode | CompanyCode |
| Currency | I_Currency | Currency |

---

## 6. RAP Objects — ZXX_ Naming Convention

| Object Type | Object Name |
|-------------|-------------|
| Interface CDS (root) | ZXX_I_SalesReport |
| Interface CDS (delivery sub) | ZXX_I_SalesReportDelivery |
| Interface CDS (invoice sub) | ZXX_I_SalesReportInvoice |
| Projection CDS (ALP) | ZXX_C_SalesReport |
| Behavior Definition | ZXX_I_SalesReport |
| Behavior Impl Class | ZXX_BP_I_SalesReport |
| Service Definition | ZXX_UI_SalesReport_O4 |
| Service Binding (OData V4) | ZXX_UI_SalesReport_O4 |
| Package | ZXX_SALES_REPORT |

---

## 7. Fiori Annotations Required

```abap
" ALP Chart — Donut: Invoice Value by Sales Org
@UI.chart: [{
  qualifier: 'InvBySalesOrg',
  chartType: #DONUT,
  dimensions: ['SalesOrganization'],
  measures: ['InvoiceValueNet'],
  title: 'Invoice Value by Sales Org'
}]

" ALP Chart — Grouped Bar: Order vs Invoice comparison
@UI.chart: [{
  qualifier: 'OrdVsInvComparison',
  chartType: #BAR_GROUPED,
  dimensions: ['SalesOrganization', 'CompanyCode'],
  measures: ['OrderValueNet', 'InvoiceValueNet'],
  title: 'Order vs Invoice by Sales Org'
}]

" KPI — Fulfilment % with criticality
@UI.dataPoint: #{
  qualifier: 'FulfilmentPct',
  value: 'FulfilmentPercent',
  title: 'Fulfilment %',
  criticalityCalculation: {
    improvementDirection: #MAXIMIZE,
    toleranceRangeLowValue: 70,
    toleranceRangeHighValue: 90
  }
}

" Selection Fields
@UI.selectionField: [
  { position: 10, element: 'CompanyCode' },
  { position: 20, element: 'SalesOrganization' },
  { position: 30, element: 'DistributionChannel' },
  { position: 40, element: 'CreationDateFrom' },
  { position: 50, element: 'CreationDateTo' }
]
```

---

## 8. Acceptance Criteria

- [ ] Filter bar shows Company Code, Sales Org, Distribution Channel, Date range
- [ ] Summary table groups data by Company Code > Sales Org > Distribution Channel
- [ ] Subtotals and grand total shown in table
- [ ] Donut chart shows invoice value split by Sales Org
- [ ] Bar chart compares Order Value vs Invoice Value per Sales Org grouped by Company Code
- [ ] Clicking chart segment filters the summary table
- [ ] KPI cards show totals with colour-coded criticality
- [ ] All data sourced via VDM views — no direct table reads
- [ ] ATC ABAP_CLOUD check passes with zero errors
- [ ] All ABAP unit tests pass
- [ ] App deployed to SAP BTP and accessible via Fiori Launchpad
- [ ] Export to Excel works on summary table

---

## 9. Open Questions

| # | Question | Owner | Status |
|---|----------|-------|--------|
| 1 | Should cancelled sales orders be excluded from the summary? | Business | Open |
| 2 | Which currency should be used for cross-company aggregation? | Finance | Open |
| 3 | Should partial deliveries be counted as one delivery or multiple? | Business | Open |
| 4 | Are credit memos and debit memos included in invoice value? | Finance | Open |
