# SAP RAP — Automated CI/CD Deployment Proposal

**Version:** 1.0 | **Date:** 2026-05-16 | **Author:** ratnadipsinha

---

## Executive Summary

This proposal defines a fully automated deployment pipeline for SAP RAP (RESTful ABAP Programming Model) applications. A developer merges code to the `main` branch in GitHub — that single action triggers the entire pipeline: static analysis, quality checks, unit tests, and deployment to SAP BTP ABAP Environment, ending with the Fiori app live in SAP Work Zone Launchpad.

**Zero manual deployment steps after the initial setup.**

---

## Current State vs. Target State

| Aspect | Current (Manual) | Target (Automated) |
|--------|-----------------|-------------------|
| Deployment trigger | Developer manually imports in Eclipse | `git push` to `main` |
| Quality checks | Ad-hoc, per developer | Enforced on every commit |
| Deploy time | 30–60 min manual steps | ~8–12 min fully automated |
| Rollback | Manual object restore | `git revert` + auto-redeploy |
| Audit trail | None / email threads | Full GitHub Actions log |
| Environment consistency | Varies per developer | Identical every time |

---

## Architecture Overview

```
Developer (Eclipse ADT)
        │  git push (feature branch)
        ▼
  GitHub Repository
  ├── feature/* branches
  ├── Pull Request + Code Review
        │  merge to main
        ▼
  GitHub Actions CI/CD Pipeline
  ├── Job 1: abapLint (static analysis)
  ├── Job 2: ATC Checks (quality gate)
  ├── Job 3: ABAP Unit Tests (≥80% coverage)
  └── Job 4: abapGit CLI Deploy (on PASS only)
        │  abapGit CLI over HTTPS
        ▼
  SAP BTP ABAP Environment
  ├── Import Queue → Activate Objects
  ├── Publish Service Binding (OData V4)
        │  auto-publish
        ▼
  SAP Fiori Launchpad (BTP Work Zone)
        │
        ▼
  Business Users — browser / mobile
```

> See `deployment-pipeline.drawio` for the full visual diagram.

---

## Technology Stack

| Tool | Role | Where Used |
|------|------|-----------|
| **Eclipse ADT** | ABAP development IDE | Developer workstation |
| **abapGit Eclipse Plugin** | Serialise ABAP objects → XML, sync with GitHub | Eclipse |
| **GitHub** | Source control, branching, PR reviews | Cloud |
| **GitHub Actions** | CI/CD automation engine | Cloud |
| **abapLint** | Static ABAP code analysis, naming rules, syntax | CI/CD Job 1 |
| **ATC (ABAP Test Cockpit)** | SAP quality gate — runs on BTP ABAP instance via REST | CI/CD Job 2 |
| **ABAP Unit Tests** | Test class execution, coverage enforcement | CI/CD Job 3 |
| **abapGit CLI** | CLI tool to push serialised objects to BTP ABAP | CI/CD Job 4 |
| **SAP BTP ABAP Environment** | Cloud ABAP runtime (target system) | SAP BTP |
| **SAP BTP HTML5 Repository** | Hosts the Fiori UI bundle | SAP BTP |
| **SAP Work Zone** | Fiori Launchpad hosting | SAP BTP |

---

## Pipeline Stages — Detailed

### Stage 1 — Developer Writes Code (Eclipse ADT)

1. Developer creates a **feature branch**: `feature/<ticket-id>-<description>`
2. RAP artifacts are written in Eclipse ADT:
   - CDS Interface Views (`ZI_*`)
   - CDS Projection Views (`ZC_*`)
   - Behavior Definitions & Implementations
   - Service Definitions & Bindings
   - Metadata Extensions
3. **abapGit Eclipse plugin** serialises each ABAP object to XML files (one file per object, structured in folders matching the package hierarchy)
4. Developer runs `git commit + push` to the feature branch

### Stage 2 — Source Control (GitHub)

1. Feature branch pushed to GitHub repository
2. Developer opens a **Pull Request** against `main`
3. At least one peer reviews and approves the PR
4. PR is **merged to `main`** — this is the single trigger point

### Stage 3 — GitHub Actions CI/CD

Triggered automatically on every push to `main`.

#### Job 1 — abapLint
- Runs `abaplint` against all serialised XML files
- Checks: ABAP syntax, naming conventions (Z-prefix, underscore rules), cyclomatic complexity, unused variables
- Config: `.abaplint.json` in repo root
- **Fail = pipeline stops, PR author notified**

#### Job 2 — ATC Checks (ABAP Test Cockpit)
- Calls BTP ABAP ATC REST API (`/sap/bc/adt/atcrun`)
- Runs SAP standard checks: security, performance, maintainability
- Uses a dedicated **CI service user** (OAuth client credentials)
- **Fail = pipeline stops**

#### Job 3 — ABAP Unit Tests
- Invokes test runner via ADT REST API
- Scope: package `ZRAP_<APP>` and all sub-packages
- Enforces minimum **80% statement coverage**
- Results exported as JUnit XML for GitHub Actions test summary
- **Fail = pipeline stops**

#### Job 4 — Deploy via abapGit CLI *(runs only if Jobs 1–3 all pass)*
- Authenticates to BTP using OAuth 2.0 client credentials (`secrets.BTP_CLIENT_ID`, `secrets.BTP_CLIENT_SECRET`)
- Runs `abapgit pull` to push the serialised XML objects into the BTP ABAP import queue
- Objects are activated automatically by abapGit
- Service binding is published via ADT REST API
- Slack / email notification sent on success or failure

### Stage 4 — SAP BTP ABAP Environment

1. **Import Queue** — abapGit CLI delivers serialised XML objects
2. **Activate ABAP Objects** — CDS views, BDEFs, classes, service definitions activated in dependency order
3. **Publish Service Binding** — OData V4 endpoint goes live (`ZUI_<APP>_O4`)
4. **Deploy Fiori UI** — `npm run build` + `cf push` or MTA deploy pushes the UI5 app bundle to the BTP HTML5 Repository

### Stage 5 — SAP Fiori Launchpad

- Content provider auto-refreshes after HTML5 repository update
- App tile appears in the Fiori Launchpad (SAP Work Zone)
- Users access via browser, mobile, or desktop — zero downtime during deploy

---

## GitHub Actions Workflow

File: `.github/workflows/deploy-rap.yml`

```yaml
name: RAP — CI/CD Deploy to BTP

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  PACKAGE: ZRAP_TRAVEL
  BTP_ABAP_HOST: ${{ secrets.BTP_ABAP_HOST }}

jobs:

  lint:
    name: abapLint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run abapLint
        uses: abaplint/abaplint@v2
        with:
          abaplint_version: latest

  atc:
    name: ATC Quality Check
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - name: Authenticate to BTP
        id: auth
        run: |
          TOKEN=$(curl -sX POST "${{ secrets.BTP_TOKEN_URL }}/oauth/token" \
            -d "grant_type=client_credentials" \
            -d "client_id=${{ secrets.BTP_CLIENT_ID }}" \
            -d "client_secret=${{ secrets.BTP_CLIENT_SECRET }}" | jq -r '.access_token')
          echo "token=$TOKEN" >> $GITHUB_OUTPUT
      - name: Run ATC
        run: |
          curl -fX POST "$BTP_ABAP_HOST/sap/bc/adt/atcrun" \
            -H "Authorization: Bearer ${{ steps.auth.outputs.token }}" \
            -H "Content-Type: application/xml" \
            -d @.github/atc-worklist.xml

  unit-tests:
    name: ABAP Unit Tests
    runs-on: ubuntu-latest
    needs: atc
    steps:
      - uses: actions/checkout@v4
      - name: Authenticate to BTP
        id: auth
        run: |
          TOKEN=$(curl -sX POST "${{ secrets.BTP_TOKEN_URL }}/oauth/token" \
            -d "grant_type=client_credentials" \
            -d "client_id=${{ secrets.BTP_CLIENT_ID }}" \
            -d "client_secret=${{ secrets.BTP_CLIENT_SECRET }}" | jq -r '.access_token')
          echo "token=$TOKEN" >> $GITHUB_OUTPUT
      - name: Run ABAP Unit Tests
        run: |
          curl -fX POST "$BTP_ABAP_HOST/sap/bc/adt/abapunit/testruns" \
            -H "Authorization: Bearer ${{ steps.auth.outputs.token }}" \
            -H "Content-Type: application/vnd.sap.adt.abapunit.testruns.config.v4+xml" \
            -d @.github/unit-test-config.xml \
            -o test-results.xml
      - name: Publish Test Results
        uses: dorny/test-reporter@v1
        with:
          name: ABAP Unit Tests
          path: test-results.xml
          reporter: java-junit

  deploy:
    name: Deploy to SAP BTP
    runs-on: ubuntu-latest
    needs: [lint, atc, unit-tests]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node (for abapGit CLI)
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install abapGit CLI
        run: npm install -g @abaplint/abapgit-cli

      - name: Authenticate to BTP
        id: auth
        run: |
          TOKEN=$(curl -sX POST "${{ secrets.BTP_TOKEN_URL }}/oauth/token" \
            -d "grant_type=client_credentials" \
            -d "client_id=${{ secrets.BTP_CLIENT_ID }}" \
            -d "client_secret=${{ secrets.BTP_CLIENT_SECRET }}" | jq -r '.access_token')
          echo "token=$TOKEN" >> $GITHUB_OUTPUT

      - name: Deploy via abapGit
        run: |
          abapgit pull \
            --host "$BTP_ABAP_HOST" \
            --token "${{ steps.auth.outputs.token }}" \
            --package "$PACKAGE"

      - name: Publish Service Binding
        run: |
          curl -fX POST "$BTP_ABAP_HOST/sap/bc/adt/businessservices/bindings/ZUI_TRAVEL_O4/publish" \
            -H "Authorization: Bearer ${{ steps.auth.outputs.token }}"

      - name: Deploy Fiori UI to HTML5 Repository
        run: |
          cd app/travel
          npm ci
          npm run build
          cf login -a "${{ secrets.CF_API }}" \
            --client-id "${{ secrets.BTP_CLIENT_ID }}" \
            --client-secret "${{ secrets.BTP_CLIENT_SECRET }}"
          mbt build
          cf deploy mta_archives/*.mtar --no-confirm

      - name: Notify Slack — Success
        if: success()
        uses: slackapi/slack-github-action@v1.25.0
        with:
          payload: |
            {
              "text": "✅ *RAP App Deployed* to BTP ABAP\nCommit: `${{ github.sha }}`\nBy: ${{ github.actor }}\n<${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}|View Pipeline>"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}

      - name: Notify Slack — Failure
        if: failure()
        uses: slackapi/slack-github-action@v1.25.0
        with:
          payload: |
            {
              "text": "❌ *RAP Deploy FAILED*\nCommit: `${{ github.sha }}`\n<${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}|View Logs>"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

---

## GitHub Repository Structure

```
/
├── .github/
│   ├── workflows/
│   │   └── deploy-rap.yml          ← CI/CD pipeline
│   ├── atc-worklist.xml            ← ATC check scope
│   └── unit-test-config.xml        ← ABAP Unit Test scope
├── .abaplint.json                  ← abapLint rules
├── src/
│   └── zrap_travel/
│       ├── zrap_travel.sap.package.xml
│       ├── zi_travel.ddls.xml      ← Interface CDS view
│       ├── zc_travel.ddls.xml      ← Projection CDS view
│       ├── zi_travel.bdef.xml      ← Behavior definition
│       ├── zbp_i_travel.clas.xml   ← Behavior implementation
│       ├── zui_travel_o4.srvd.xml  ← Service definition
│       └── zui_travel_o4.srvb.xml  ← Service binding
└── app/
    └── travel/
        ├── package.json
        ├── ui5.yaml
        └── webapp/                 ← Fiori UI5 app
```

---

## Secrets Configuration (GitHub)

| Secret Name | Value | Used In |
|-------------|-------|---------|
| `BTP_ABAP_HOST` | `https://<guid>.abap.eu10.hana.ondemand.com` | All jobs |
| `BTP_TOKEN_URL` | `https://<subaccount>.authentication.eu10.hana.ondemand.com` | Auth steps |
| `BTP_CLIENT_ID` | OAuth client ID from BTP service key | Auth steps |
| `BTP_CLIENT_SECRET` | OAuth client secret from BTP service key | Auth steps |
| `CF_API` | `https://api.cf.eu10.hana.ondemand.com` | UI deploy |
| `SLACK_WEBHOOK_URL` | Incoming webhook URL | Notifications |

---

## Branching Strategy

```
main ────────────────────────────────────── (protected, deploys to BTP)
  └── develop ──────────────────────────── (integration branch, optional)
        ├── feature/RAP-001-travel-bo
        ├── feature/RAP-002-booking-entity
        └── hotfix/RAP-010-date-validation
```

**Branch protection rules on `main`:**
- Require PR + 1 approval before merge
- Require all status checks to pass (abapLint + ATC + Unit Tests)
- No direct pushes to `main`

---

## abapGit Configuration

File: `src/.abapgit.xml` (in the ABAP system, linked to the GitHub repo)

```xml
<?xml version="1.0" encoding="utf-8"?>
<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
    <DATA>
      <MASTER_LANGUAGE>E</MASTER_LANGUAGE>
      <STARTING_FOLDER>/src/</STARTING_FOLDER>
      <FOLDER_LOGIC>PREFIX</FOLDER_LOGIC>
      <IGNORE>
        <item>/.git/</item>
        <item>/.github/</item>
        <item>/app/</item>
      </IGNORE>
    </DATA>
  </asx:values>
</asx:abap>
```

---

## Rollback Strategy

| Scenario | Action |
|----------|--------|
| Bad deploy caught before users notice | `git revert <sha>` → push to main → pipeline auto-redeploys previous version |
| Critical production issue | Create hotfix branch → fast-track PR → merge → pipeline deploys in ~8 min |
| Corrupt ABAP objects | Manual `abapgit pull` from last known-good git tag on BTP |
| UI-only regression | Redeploy HTML5 bundle from previous GitHub Actions artifact |

---

## BTP Setup Prerequisites

1. **BTP ABAP Environment instance** provisioned in your BTP subaccount
2. **Service key** created for the ABAP instance (type: `Communication Arrangement` or `ABAP Instance`)
3. **Communication Arrangement** `SAP_COM_0510` (for abapGit) activated in the ABAP instance
4. **Communication Arrangement** `SAP_COM_0748` (for ATC REST API) activated
5. **Communication Arrangement** `SAP_COM_0715` (for ABAP Unit Test REST API) activated
6. **SAP Work Zone** (Standard or Advanced) subscription in BTP subaccount
7. **Cloud Foundry space** for MTA/HTML5 deployment (`cf login` in pipeline)
8. **HTML5 Application Repository** service instance created

---

## Quality Gates Summary

| Gate | Tool | Threshold | On Fail |
|------|------|-----------|---------|
| Syntax & naming | abapLint | Zero errors | Block merge, notify dev |
| SAP code quality | ATC | Zero priority-1 findings | Block merge, notify dev |
| Test coverage | ABAP Unit Tests | ≥ 80% statement coverage | Block merge, notify dev |
| Manual review | GitHub PR | 1 approver | Block merge |

---

## Implementation Timeline

| Week | Task | Owner |
|------|------|-------|
| 1 | Set up GitHub repo + abapGit Eclipse plugin + link to BTP system | Dev Lead |
| 1 | Create BTP communication arrangements for CI user | Basis / BTP Admin |
| 1 | Add GitHub Secrets for BTP credentials | DevOps |
| 2 | Write `.github/workflows/deploy-rap.yml` + test lint job | Dev |
| 2 | Configure `.abaplint.json` rules for project standards | Dev Lead |
| 2 | Configure ATC scope XML and test ATC REST API call | Dev |
| 3 | Add ABAP Unit Test job + test results reporting | Dev |
| 3 | End-to-end test: push → all gates → deploy to BTP ABAP | Dev + BTP Admin |
| 4 | Configure Fiori UI MTA deploy in pipeline | Frontend Dev |
| 4 | Set up Work Zone content provider + test Launchpad tile | BTP Admin |
| 4 | Document runbook + onboard rest of team | Dev Lead |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|-----------|
| BTP ABAP API rate limits during CI | Low | Medium | Cache OAuth tokens; run checks sequentially not in parallel |
| abapGit activation errors on BTP | Medium | High | Test `abapgit pull` manually first; add pre-check step in pipeline |
| ATC findings from existing code | High | Medium | Start with warning-only gate; tighten to error after backlog cleared |
| Secrets rotation breaks pipeline | Low | High | Store secrets in GitHub with expiry reminders; use BTP binding where possible |
| Long pipeline runtime blocks PRs | Medium | Low | Parallelize abapLint; cache npm; skip UI deploy on non-main branches |

---

## Success Metrics

- Deploy frequency: **daily or more** (vs. current weekly)
- Lead time for changes: **< 15 min** (code merge → live in Launchpad)
- Change failure rate: **< 5%** (blocked by quality gates before reaching BTP)
- Mean time to restore: **< 30 min** (via `git revert` + pipeline)
- Manual deployment steps: **0** (after initial setup)
