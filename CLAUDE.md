# SAP RAP Project — Claude Code Configuration

## Project Overview
This project builds SAP RAP (RESTful ABAP Programming Model) applications on SAP BTP ABAP Environment using a fully automated CI/CD pipeline.

**Stack:** Claude Code → GitHub → Eclipse ADT (abapGit) → GitHub Actions → SAP BTP

**Central config:** [project.config.yml](project.config.yml) — all repo URLs, BTP host, package names, ATC settings, naming conventions in one place. Read this before generating any object names or pipeline configs.

---

## Folder Structure

```
ABAP RAP report/
├── CLAUDE.md                      ← you are here
├── docs/                          ← proposals, specs, documentation
├── diagrams/                      ← draw.io pipeline diagrams
├── skills/                        ← Claude skill files (load before generating)
│   ├── SAP-NAMING-CONVENTION.md   ← ZXX_ prefix rules — load FIRST
│   ├── SAP-FIORI-DESIGNER.md      ← floor plan decisions — load SECOND
│   ├── SAP-RAP-DEVELOPER.md       ← code generation — load THIRD
│   └── SAP-CLEAN-CORE.md          ← compliance review — load LAST
└── src/                           ← generated ABAP source files (.abap, .xml)
    └── ZXX_*.abap
```

---

## Skill Usage — Mandatory Sequence

Always invoke skills in this order for every new feature:

| Step | Command | Purpose |
|------|---------|---------|
| 1 | `/sap-fiori-designer` | Decide floor plan, sections, facets |
| 2 | `/sap-naming-convention` | Generate all ZXX_ object names |
| 3 | `/sap-rap-developer` | Generate CDS, BDEF, handler class |
| 4 | `/sap-clean-core` | Review code for compliance |

**Never generate code before naming. Never deploy before clean core review.**

---

## Naming Convention — Non-Negotiable

All custom objects **must** use the `ZXX_` prefix. No exceptions.

```
ZXX_          → DB tables, packages
ZXX_I_        → interface CDS views
ZXX_C_        → projection CDS views
ZXX_I_VH_     → value help views
ZXX_BP_I_     → behavior implementation (interface)
ZXX_BP_C_     → behavior implementation (projection)
ZXX_UI_       → service definition / binding (Fiori UI)
ZXX_API_      → service binding (Web API)
ZXX_CL_       → global classes
ZXX_IF_       → global interfaces
ZXX_CX_       → exception classes
ZXX_ATC_      → custom ATC check classes
```

See full reference: [skills/SAP-NAMING-CONVENTION.md](skills/SAP-NAMING-CONVENTION.md)

---

## Code Generation Rules

1. **Always use released APIs (C1 contract)** — never read SAP standard tables directly
2. **Use VDM views** — `I_Product`, `I_BusinessPartner` etc. instead of `mara`, `but000`
3. **No COMMIT WORK** inside RAP handler methods — framework manages LUW
4. **Use `%tky`** not `%key` when draft is enabled
5. **Strict mode** — always include `strict ( 2 )` in new BDEFs
6. **Mapping** — always define `mapping for` explicitly in BDEF
7. **Messages** — use `reported` table + `new_message_with_text()`, never `MESSAGE`

See full reference: [skills/SAP-RAP-DEVELOPER.md](skills/SAP-RAP-DEVELOPER.md)

---

## Clean Core Rules

- No modifications to SAP standard objects
- No direct SELECT on SAP standard tables
- No `SUBMIT`, `CALL TRANSACTION`, `OPEN DATASET`
- ATC check variant `ABAP_CLOUD` must pass with zero errors
- Extensions only via BAdI or RAP extension points

See full reference: [skills/SAP-CLEAN-CORE.md](skills/SAP-CLEAN-CORE.md)

---

## Pipeline Flow

```
Claude generates code → writes to src/ folder
      ↓
Push to GitHub (feature branch)
      ↓
Eclipse ADT pulls from GitHub via abapGit plugin
      ↓
ATC runs automatically in Eclipse (check variant: ABAP_CLOUD)
  FAIL → fix in Claude → push again
  PASS → developer activates objects in SAP system
      ↓
PR merged to main on GitHub
      ↓
Eclipse pulls main branch → abapGit syncs to BTP
      ↓
Fiori app live on OData V4
```

**GitHub = code storage + version control only. No secrets. No Actions.**

**ATC setup in Eclipse:**
`Window → Preferences → ABAP Development → ATC → check variant: ABAP_CLOUD → Enable: Run ATC before transport`

**abapGit setup in Eclipse:**
`abapGit plugin → Clone → paste GitHub repo URL → link to package ZXX_REPORTS`

See pipeline diagram: [diagrams/deployment-pipeline.drawio](diagrams/deployment-pipeline.drawio)

---

## src/ Folder — ABAP Source Files

Generated ABAP files go into `src/` following abapGit serialisation format:

```
src/
├── zxx_travel.tabl.xml             ← DB table
├── zxx_i_travel.ddls.asddls        ← interface CDS view
├── zxx_c_travel.ddls.asddls        ← projection CDS view
├── zxx_i_travel.bdef.asbdef        ← behavior definition
├── zxx_bp_i_travel.clas.abap       ← behavior implementation
├── zxx_bp_i_travel.clas.xml        ← class metadata
└── zxx_ui_travel_o4.srvd.asrvd     ← service definition
```

Eclipse ADT reads from this folder via abapGit. No manual copy needed.
