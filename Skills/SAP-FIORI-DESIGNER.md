# SAP Fiori Designer — Floor Plan Reference

> Source: SAP Fiori Design Guidelines (experience.sap.com/fiori-design-web)
> Version reference: v1-38 through v1-145

---

## Floor Plan Overview

A **floor plan** defines the overall page layout, structure of controls, and interaction patterns for a whole page. Floor plans are the foundation of SAP Fiori apps — choose the right one before writing any code.

```
┌──────────────────────────────────────────────────────────────┐
│                     CHOOSE A FLOOR PLAN                       │
│                                                              │
│  Large dataset + find/act  →  List Report                    │
│  Small set + process items →  Worklist                       │
│  Single object detail      →  Object Page                    │
│  Data analysis + drilldown →  Analytical List Page (ALP)     │
│  Role dashboard / cards    →  Overview Page (OVP)            │
│  Side-by-side navigation   →  Flexible Column Layout         │
└──────────────────────────────────────────────────────────────┘
```

---

## 1. List Report Floorplan

### What It Is
The primary floor plan for displaying and working with **large sets of items**. Combines a filter bar with a table or chart to let users find, filter, sort, group, and act on items.

### When to Use
- Users need to search, filter, sort, or group within a large dataset
- Multiple objects need to be selected and acted on simultaneously
- The use case is analytical but does NOT require root-cause investigation or drill-down (use ALP for that)
- Replacing an SAP GUI report or transaction list

### When NOT to Use
- Small, task-focused item set → use **Worklist**
- Single object display/edit → use **Object Page**
- Data analysis with charts + drill-down → use **Analytical List Page**

### Page Structure

```
┌─────────────────────────────────────────────────────────┐
│  Shell Bar (global nav)                                  │
├─────────────────────────────────────────────────────────┤
│  Page Title                    [Go] [Filters] [Variants] │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  Filter Bar (SmartFilterBar)                        │ │
│  │  Field 1 [    ]  Field 2 [    ]  Field 3 [    ]    │ │
│  └─────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  Table Toolbar: Title (n)  [Create][Edit][Delete]   │ │
│  │  [Sort][Group][Settings]                            │ │
│  │  ┌───────────────────────────────────────────────┐  │ │
│  │  │  Table / Grid / Analytical / Tree Table       │  │ │
│  │  └───────────────────────────────────────────────┘  │ │
│  └─────────────────────────────────────────────────────┘ │
│  [Footer Toolbar — Edit/Save/Cancel, if applicable]      │
└─────────────────────────────────────────────────────────┘
```

### Key Components

| Component | Notes |
|-----------|-------|
| **Filter Bar** | Mandatory. SmartFilterBar with field-level search and variant management |
| **Table** | SmartTable — can render Responsive, Grid, Analytical, or Tree Table |
| **Table Toolbar** | Title with item count, CRUD buttons, sort/group/column settings |
| **Footer Toolbar** | Appears in edit mode; contains Save / Cancel / Apply |
| **Variant Management** | User can save and load filter+table personalization sets |

### Table Types

| Type | Use When |
|------|----------|
| **Responsive Table** | Mobile-first; works on all screen sizes; simple flat data |
| **Grid Table** | Large column count; desktop only; high-density data |
| **Analytical Table** | Grouping, subtotals, tree-like hierarchy in rows |
| **Tree Table** | Hierarchical data with parent-child rows |

### Draft Handling
- Annotate entity with `@odata.draft.enabled: true` to enable draft
- Draft indicator column shown automatically in the table
- Users can resume incomplete edits; draft is discarded on activation or discard action
- Filter bar includes draft filter by default (can be disabled)

### Annotations (SAP Fiori Elements)
```cds
@UI.lineItem: [{ position: 10, label: 'ID' }]
@UI.selectionField: [{ position: 10 }]
@UI.headerInfo: { typeName: 'Order', typeNamePlural: 'Orders' }
```

---

## 2. Object Page Floorplan

### What It Is
The standard floor plan for **displaying, creating, and editing a single business object** in full detail. Replaced the older Detail Page and Form Page patterns.

### When to Use
- Display or edit all attributes and related data of a single object
- Object has multiple sections of information (address, items, notes, attachments)
- Users navigate here from a List Report, Worklist, or ALP
- Creating a new object with a multi-section form

### When NOT to Use
- Very simple create/edit with only a few fields → use a dialog or simple form instead
- Object list display → use **List Report**

### Page Structure

```
┌─────────────────────────────────────────────────────────┐
│  Shell Bar                                               │
│  Breadcrumb: App > List > Object Name                   │
├────────────────────────────────────────────────────────┤
│  DYNAMIC HEADER (collapses on scroll)                    │
│  ┌────────────────────────────────────────────────────┐  │
│  │ Object Title     Object Subtitle    [Edit][Delete]  │  │
│  │ ─────────────────────────────────────────────────  │  │
│  │ Header Facets:                                      │  │
│  │  [KPI 1]  [Status]  [Date Range]  [Contact]        │  │
│  └────────────────────────────────────────────────────┘  │
├────────────────────────────────────────────────────────┤
│  ANCHOR BAR: [Section 1] [Section 2] [Section 3] ...    │
├────────────────────────────────────────────────────────┤
│  Section 1: General Information                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Field Group: Basic Data                         │   │
│  │  Label: Value    Label: Value    Label: Value    │   │
│  └──────────────────────────────────────────────────┘   │
│  Section 2: Items                                        │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Smart Table / Chart                             │   │
│  └──────────────────────────────────────────────────┘   │
│  [Footer: Save | Cancel]  (edit mode only)              │
└─────────────────────────────────────────────────────────┘
```

### Key Components

| Component | Notes |
|-----------|-------|
| **Dynamic Page Header** | Collapses on scroll; use dynamic header, NOT old object header |
| **Header Title** | Object name, subtitle, breadcrumb, global action buttons |
| **Header Facets** | Inline containers showing KPIs, status, data previews |
| **Anchor Bar** | Horizontal nav links to sections; stays visible on scroll |
| **Sections / Subsections** | Content grouped into sections; can contain field groups or tables |
| **Field Groups** | Label-value pairs rendered in a grid layout |
| **Footer Bar** | Edit mode: Save, Cancel, Apply; display mode: hidden |

### Header Facet Types

| Facet Type | Use For |
|------------|---------|
| `DataPoint` | KPIs, numeric values with criticality (red/green/yellow) |
| `Contact` | Person details with avatar |
| `FlatCollection` | Multiple label-value pairs |
| `ReferenceData` | Links to related objects |
| `MicroChart` | Sparkline, bullet, radial micro charts |

### Sections via Annotations
```cds
@UI.facet: [
  { id: 'GeneralInfo',
    purpose: #STANDARD,
    type: #FIELDGROUP_REFERENCE,
    label: 'General Info',
    targetQualifier: 'GeneralInfo',
    position: 10 },
  { id: 'Items',
    purpose: #STANDARD,
    type: #LINEITEM_REFERENCE,
    label: 'Items',
    position: 20 }
]
@UI.fieldGroup: [{ qualifier: 'GeneralInfo', position: 10 }]
@UI.identification: [{ position: 10 }]
```

### Edit Modes
| Mode | Behaviour |
|------|-----------|
| **Display** | Read-only; Edit button in header |
| **Edit** | Inline edit; footer with Save/Cancel |
| **Create** | Full page form; all fields editable |
| **Draft** | Auto-save; Resume/Discard from list |

---

## 3. Worklist Floorplan

### What It Is
A simplified list floor plan optimised for **processing a small set of work items one by one**. Focus is on action, not browsing.

### When to Use
- Users must work through every item in the list (approve, reject, delegate, complete)
- Set is small and bounded — not open-ended search
- No complex filtering required (a simple search bar is sufficient)
- Clear end state: item is "done" after action

### When NOT to Use
- Large open-ended dataset → use **List Report**
- Items need complex filtering or multi-criteria search → use **List Report**
- Analytical insight needed → use **ALP**

### Worklist vs. List Report

| Aspect | Worklist | List Report |
|--------|----------|-------------|
| Dataset size | Small, bounded | Large, open-ended |
| Primary goal | Process each item | Find relevant items |
| Filter bar | Simple search only | Full SmartFilterBar |
| Variant management | Not needed | Supported |
| Typical actions | Approve / Reject / Delegate | Create / Edit / Delete |

### Page Structure

```
┌──────────────────────────────────────────────────────┐
│  Shell Bar                                            │
├──────────────────────────────────────────────────────┤
│  Page Title                      [Search ________]   │
│  ┌────────────────────────────────────────────────┐  │
│  │ Table Toolbar: Title (n) [Action 1][Action 2]  │  │
│  │ ┌──────────────────────────────────────────┐   │  │
│  │ │  Responsive Table (items to process)     │   │  │
│  │ └──────────────────────────────────────────┘   │  │
│  └────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

### KPI Worklist Variant
A **KPI Worklist** adds a KPI header above the table to track a metric while processing items (e.g., "Pending Approvals: 24 / Total Amount: €180K").

---

## 4. Analytical List Page (ALP)

### What It Is
A specialised list floor plan that combines **data visualisation with transactional action**. Enables users to analyse data from different perspectives, drill down to root causes, and act — all on one page.

### When to Use
- Users need to identify exceptions, outliers, or trends in large datasets
- Drill-down from chart → filtered table is a core interaction
- KPI monitoring combined with item-level actions
- Replacing SAP GUI analytical reports that also have action capability

### When NOT to Use
- Simple reporting without action → use a pure BI tool (SAP Analytics Cloud)
- Trivial filter + table with no analytics → use **List Report**
- Single object detail → use **Object Page**

### Page Structure

```
┌──────────────────────────────────────────────────────────┐
│  Shell Bar                                                │
├──────────────────────────────────────────────────────────┤
│  KPI Tag Bar (optional):                                  │
│  [Revenue ▲12%]  [Open Orders: 342]  [Exceptions: 17]    │
├──────────────────────────────────────────────────────────┤
│  FILTER AREA (toggle: Visual Filter | Compact Filter)     │
│  ┌───────────────────────────────────────────────────┐   │
│  │ Visual Filter:  [Bar Chart] [Line Chart] [Donut]  │   │
│  │  (click chart bar to filter content area)         │   │
│  └───────────────────────────────────────────────────┘   │
├──────────────────────────────────────────────────────────┤
│  CONTENT AREA (toggle: Chart | Table | Chart+Table)       │
│  ┌───────────────────────────────────────────────────┐   │
│  │ [Chart view — click segment to drilldown]         │   │
│  │ [Table view — act on filtered items]              │   │
│  └───────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

### Key Components

| Component | Notes |
|-----------|-------|
| **KPI Tags** | Numeric KPIs with trend arrows and criticality colours at top of page |
| **Visual Filter** | Interactive mini charts (bar, line, donut) — clicking filters content |
| **Compact Filter** | Traditional field-based filter bar (alternative to visual filter) |
| **Chart Area** | Full chart driven by filter selections; supports drill-down |
| **Table Area** | Shows data filtered by chart selection; actions available |
| **Chart+Table** | Split view: chart on top, table below — linked selections |

### Filter Modes

| Mode | Description |
|------|-------------|
| **Visual Filter** | Charts as filters — intuitive for data exploration |
| **Compact Filter** | Standard filter bar — for users who know exact filter values |

### Notes
- ALP is only fully supported in Flexible Column Layout **without KPIs**
- If using KPIs in FCL, ensure column size ≥ M
- On size S (mobile): supports chart-only or table-only view

### Key Annotation
```cds
@UI.chart: [{
  chartType: #BAR,
  dimensions: ['Category'],
  measures: ['Amount'],
  qualifier: 'ByCategory'
}]
```

---

## 5. Overview Page (OVP)

### What It Is
A **role-based dashboard** that gives users a single-page view of all information relevant to their domain or role, presented as interactive cards. The starting point for a business process.

### When to Use
- Providing a home screen / launchpad for a specific role or domain
- Aggregating information from multiple apps or data sources
- Users need a quick status overview before drilling into details
- Replacing a custom portal or iView dashboard

### When NOT to Use
- Single focused task → use **List Report** or **Worklist**
- Deep data analysis → use **ALP**
- Object maintenance → use **Object Page**

### Page Structure

```
┌──────────────────────────────────────────────────────────┐
│  Shell Bar                                                │
├──────────────────────────────────────────────────────────┤
│  Page Header: Title  [Global Filter Bar]                  │
├──────────────────────────────────────────────────────────┤
│  Card Canvas (responsive grid layout)                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐        │
│  │  List Card  │ │ Chart Card  │ │  KPI Card   │        │
│  │  (items)    │ │ (bar/line)  │ │  (metric)   │        │
│  └─────────────┘ └─────────────┘ └─────────────┘        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐        │
│  │  Table Card │ │ Image Card  │ │  Stack Card │        │
│  └─────────────┘ └─────────────┘ └─────────────┘        │
└──────────────────────────────────────────────────────────┘
```

### Card Types

| Card Type | Shows | Navigation |
|-----------|-------|------------|
| **List Card** | Ordered list of items with status | → Object Page or List Report |
| **Table Card** | Tabular data with multiple columns | → List Report |
| **Bar Chart Card** | Bar chart for comparisons | → ALP |
| **Line Chart Card** | Trend over time | → ALP |
| **Donut Chart Card** | Part-to-whole proportions | → ALP |
| **KPI Card** | Single metric with trend | → ALP or List Report |
| **Quick View Card** | Detail of a single object (contact, address) | → Object Page |
| **Stack Card** | Multiple object previews stacked | → Object Page |
| **Analytical Card** | Composite analytics view | → ALP |

### Global Filter
The OVP global filter applies to **all cards simultaneously** — a key differentiator from a plain launchpad. Users set a date range, company code, or other parameter and all cards refresh at once.

---

## 6. Flexible Column Layout (FCL)

### What It Is
A **layout pattern** (not a floor plan itself) that displays 2 or 3 floor plans **side by side** in columns, enabling fast in-context navigation without full-page transitions.

### When to Use
- Master-detail scenario: list on left, object detail on right
- Master-detail-detail: list → object → sub-object (3 columns)
- Users frequently switch between list and detail (e.g., approve one by one)
- You have ≥ 2 navigation levels in the app

### When NOT to Use
- Workbench or tools layout (e.g., code editor with panels)
- Only one navigation level
- Mobile-only app (FCL degrades to single column on small screens)

### Column Configurations

| Layout Name | Columns | Column Ratio | Use When |
|-------------|---------|--------------|----------|
| `OneColumn` | 1 | 100% | Initial / full screen |
| `TwoColumnsBeginExpanded` | 2 | 67% / 33% | List prominent |
| `TwoColumnsMidExpanded` | 2 | 33% / 67% | Detail prominent |
| `ThreeColumnsMidExpanded` | 3 | 25% / 50% / 25% | Detail with sub-detail |
| `ThreeColumnsEndExpanded` | 3 | 25% / 25% / 50% | Sub-detail prominent |
| `MidColumnFullScreen` | 1 (mid) | 100% | Focus on detail |
| `EndColumnFullScreen` | 1 (end) | 100% | Focus on sub-detail |

### Typical App Flows

```
Full Screen Layout (simple):
  List Report  →  (navigate)  →  Object Page  (full page transition)

Flexible Column Layout (recommended):
  ┌─────────────┬──────────────────────────┐
  │ List Report │  Object Page             │  2-column
  └─────────────┴──────────────────────────┘

  ┌───────────┬─────────────┬──────────────┐
  │ List      │ Object Page │ Sub-Object   │  3-column
  └───────────┴─────────────┴──────────────┘
```

### SAP Fiori Elements Integration
In `manifest.json`, set:
```json
"sap.ui5": {
  "routing": {
    "config": {
      "routerClass": "sap.f.routing.Router"
    }
  }
}
```
And use `sap.f.FlexibleColumnLayout` as the root control.

---

## Floor Plan Decision Matrix

| Scenario | Recommended Floor Plan |
|----------|----------------------|
| Browse and act on large dataset | List Report |
| Process a small task queue | Worklist |
| Display/edit a single object | Object Page |
| Analyse data + act on results | Analytical List Page |
| Role-based home dashboard | Overview Page |
| List + detail side-by-side | List Report + Object Page in FCL |
| 3-level drill-down | List Report + Object Page + Sub-Object in FCL |
| KPI monitoring with drill-down | Analytical List Page (+ ALP in FCL) |

---

## SAP Fiori Elements vs. Freestyle

| Approach | When to Use |
|----------|-------------|
| **SAP Fiori Elements** | Standard floor plan needed; annotation-driven; fast development; consistent UX |
| **Freestyle (SAPUI5)** | Custom layout not covered by a floor plan; complex UI logic; existing component reuse |

> Always prefer SAP Fiori Elements for standard floor plans — it drives UX consistency and reduces UI code significantly.

---

## Annotation Cheat Sheet

```cds
" ── List Report ──────────────────────────────────
@UI.lineItem: [{ position: 10 }]           " table column
@UI.selectionField: [{ position: 10 }]     " filter bar field
@UI.headerInfo: { typeName: 'Travel', typeNamePlural: 'Travels',
  title: { type: #STANDARD, value: 'TravelId' } }

" ── Object Page Header ───────────────────────────
@UI.identification: [{ position: 10 }]     " title area
@UI.dataPoint: #{ value: 'Status',
  criticality: 'CriticalityCode' }         " KPI in header

" ── Object Page Sections ─────────────────────────
@UI.facet: [{
  id: 'General', purpose: #STANDARD,
  type: #FIELDGROUP_REFERENCE,
  targetQualifier: 'General', position: 10
}]
@UI.fieldGroup: [{ qualifier: 'General', position: 10 }]

" ── Object Page Actions ──────────────────────────
@UI.identification: [{ type: #FOR_ACTION,
  dataAction: 'AcceptTravel', label: 'Accept' }]

" ── ALP Chart ────────────────────────────────────
@UI.chart: [{ chartType: #BAR,
  dimensions: ['Region'], measures: ['Revenue'],
  qualifier: 'ByRegion' }]

" ── KPI (ALP / OVP) ──────────────────────────────
@UI.dataPoint: #{ value: 'TotalRevenue',
  title: 'Revenue', criticalityCalculation: {
    improvementDirection: #TARGET,
    toleranceRangeLowValue: 80,
    toleranceRangeHighValue: 120 } }
```

---

## Sources
- [Overview – Layouts, Floorplans, and Frameworks](https://experience.sap.com/fiori-design-web/v1-50/floorplan-overview/)
- [List Report Floorplan](https://experience.sap.com/fiori-design-web/list-report-floorplan-sap-fiori-element/)
- [Object Page Floorplan](https://experience.sap.com/fiori-design-web/object-page/)
- [Analytical List Page](https://experience.sap.com/fiori-design-web/analytical-list-page/)
- [Worklist Floorplan](https://experience.sap.com/fiori-design-web/v1-52/work-list/)
- [When to Use Which Floorplan](https://experience.sap.com/fiori-design-web/when-to-use-which-floorplan/)
- [Flexible Column Layout](https://www.sap.com/design-system/fiori-design-web/v1-84/page-types/page-layouts/flexible-column-layout/usage)
- [SAP Fiori Elements Overview](https://pathlock.com/blog/sap-fiori/sap-fiori-elements/)
