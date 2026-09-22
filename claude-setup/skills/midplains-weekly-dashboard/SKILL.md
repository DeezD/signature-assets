---
name: midplains-weekly-dashboard
description: >
  Produce the weekly Mid-Plains (branch 1156) production dashboard by refreshing the
  DASHBOARD_DATA object embedded in the HTML template, computing week-over-week deltas
  from last week's file, validating, exporting a dated PDF, and archiving inputs.
  Use when the user says "run the weekly dashboard," "update the Mid-Plains dashboard,"
  drops the weekly FFIG reports in the MP-Dashboard Inbox, or asks for "week NN dashboard."
---

# Mid-Plains Weekly Dashboard Update

## Outcome
A new `midplainsdashboardwkNN.html` plus a dated PDF, both delivered to Dustin
and committed to the MP-Dashboard root, with the prior week's inputs archived
and the Inbox empty.

## Hard boundaries
- **Never carry stale numbers forward silently.** If any of input files 1-6 is
  missing, stop and ask. File 7 is optional; note its absence and continue.
- **Never edit anything below the `/* RENDERING */` divider.** Only the
  `const DASHBOARD_DATA = {...};` block changes.
- **Never publish without the checks passing** - cross-foot, `node --check`,
  and a headless render with no console errors. A dashboard that renders wrong
  numbers is worse than a late one.
- **Never delete on the device.** `rm` is blocked; use `mv` only.
- Internal use only. The footer's non-distribution notice stays intact.
- Identify inputs by content, not filename - names vary week to week.

## Overview

The dashboard is a single self-contained HTML file (`midplainsdashboardwkNN.html`). All
numbers live in one JavaScript object, `const DASHBOARD_DATA = {...}`, near the top of the
`<script>` block. The weekly job is: extract Mid-Plains-only figures from six input
reports (seven files), build a new DASHBOARD_DATA object, splice it into a copy of last week's HTML
(which also supplies the `prior` values and sparkline `history` for WoW deltas), validate,
export a PDF, and archive everything.

**Template notes:** fonts (Fraunces/Inter) are base64-embedded —
the file needs no network. LOB dot colors reference `--c-*` CSS variables, a
CVD-validated categorical palette — copy the `color`/`cat` fields verbatim each week and
never swap them back to the old `--ink`/`--plum` values. Category icons are keyed off row
labels by `iconFor()` in the rendering code, so keep LOB labels spelled exactly as-is.
The `history` object drives sparklines; maintain it per Step 4.

**Folder layout** (Box, connected via device bridge):
```
MP-Dashboard/
├── midplainsdashboardwkNN.html   ← current dashboard (template + last week's data)
├── Inbox/                        ← Dustin drops the 6 weekly input files here
└── Archive/                      ← processed inputs + superseded dashboards, by week
```

## The 7 input files

| # | File | Format | Scope | Feeds |
|---|------|--------|-------|-------|
| 1 | `2026 FFIG Distribution Report - Week NN.pdf` | PDF | All offices — **use the Mid-Plains row** | `meta.weekLabel`, entire `hero` block, `total`, plan figures |
| 2 | `YTD FYCC Report by Advisor and LOB MidPlains.xlsx` | XLSX (Sheet1) | Mid-Plains advisors only | `lob`, `core`, `osaic`, all Top-5 cards, `management`, `trip` |
| 3 | `WTD New Business Detail Report.csv` | CSV | All branches — **filter `Branch == "1156 - Mid-Plains"`** | `topSubmittedWtd` |
| 4 | Producer Group Ranking — arrives as `FFIGRankYearPG.pdf` OR `FFIGPGMgmtBranchRpt_MidPlains_NNYYYY.XLS` | PDF or XLS | Mid-Plains only (115600) | `groups` |
| 5 | `FFIG Advisor Recruiting Report.xlsx` | XLSX | All branches — **use row Branch ID 1156** | `recruiting` |
| 6 | `New Advisor Paid and Pending Report MidPlains.pdf` | PDF | Mid-Plains only | `top5New` |
| 7 | `Sales Builder Report.pdf` — **OPTIONAL** (published only every few weeks) | PDF | Company-wide — **filter Branch "1156 - Mid-Plains"** | Cross-check for `trip.qualified` tiers |

Files 1–6 are required: if any is missing from Inbox, stop and ask before proceeding — do
not carry stale numbers forward silently. File 7 (Sales Builder) is optional: when absent,
skip the trip-tier cross-check and note that in the output summary; never block the run
on it. Identify files by content, not exact filename — names vary week to week.

## Step-by-step process

### 1. Stage inputs and last week's dashboard

Stage the seven Inbox files **plus** the current `midplainsdashboardwkNN.html` from the
MP-Dashboard root (it is both the template and the source of prior-week values). Copy the
HTML out of the read-only uploads mount before editing.

### 2. Determine the week

Week number and Friday date come from the Distribution Report header (e.g. "Week 32 ·
Aug 7, 2026"). Set:

- `meta.weekLabel` — `"Week NN · <Month D, YYYY>"`
- `meta.generated` — keep the standard source-listing string
- `meta.baselineWeek` — `false` (only `true` if there is no prior-week file)

### 3. Extract Mid-Plains data, field by field

All amounts are whole dollars (round; strip commas from CSV/PDF values).

**`hero` — from Distribution Report, Mid-Plains row:**

| Field | Distribution Report column |
|-------|---------------------------|
| `issuedFycYtd` | YTD Core + INV + P&C FYCC (Paid) |
| `planYtd` | YTD Plan |
| `nbPending` | Pending FYC's New Business |
| `submittedWtd` | Submitted WTD FYCC |
| `submittedL4W` | Last 4-Weeks Submitted |
| `paidWtd` | Paid WTD FYCC |

**`lob`, `core`, `osaic` YTD — from YTD FYCC xlsx (Sheet1), summing columns across all
Mid-Plains advisors:** Life = `Life FYCC`, Long-Term Care = `LTC FYCC`, Disability =
`DI FYCC`, Annuity = `Annuity FYCC`, Health/Medicare = `Health FYCC`, ACA = `ACA FYCC`,
`core.ytd` = `Core FYCC` sum, `osaic.ytd` = `INV FYCC` sum, `total.ytd` = `Total FYCC` sum.

**Plan proration** (goals are fixed 2026 AOP targets already in the template — Life
425,000 · Annuity 1,100,000 · Health 850,000 · ACA 25,000 · Core 2,400,000 · Osaic
1,900,000 · Total 4,300,000):

- Life plan = 425,000 × NN/52; Annuity plan = 1,100,000 × NN/52; Osaic plan = 1,900,000 × NN/52 (straight-line)
- `total.plan` = Mid-Plains YTD Plan from the Distribution Report (not computed)
- Health + ACA plan (Medicare is seasonal, not straight-line): remainder method —
  `healthAcaPlan = total.plan − lifePlan − annuityPlan − osaicPlan`, then split pro-rata
  by goal: Health = remainder × 850/875, ACA = remainder × 25/875
- `core.plan` = sum of the six LOB plans; LTC and DI have no plan/goal (`null`)
- Sanity: core.plan + osaic.plan must equal total.plan to the dollar

**`vpy`** (vs prior year): core and total VPY% come straight from the Distribution Report
Mid-Plains row. Per-LOB vpy: carry the methodology from the prior file (PY comparison);
set `null` where no PY figure is available.

**Top-5 cards — from YTD FYCC xlsx, Mid-Plains advisors, sorted descending:**

- `top5Overall` — top 5 by `Total FYCC`
- `top5[0]` Life Insurance — top 5 by `Life + LTC + DI FYCC`
- `top5[1]` Annuity — top 5 by `Annuity FYCC`
- `top5[2]` Health/Medicare/ACA — top 5 by `Health + ACA FYCC`
- `top5[3]` Investments (Osaic) — top 5 by `INV FYCC`
- `topCore` — top 5 by `Core FYCC`
- `top5New` — from the **New Advisor Paid & Pending Report PDF** (365-day window),
  NOT the YTD FYCC file: rank by the `Core+INV Total` column (paid + pending since
  joining), excluding advisors with a Term Date. Top 5. Row subtitle =
  `"Joined <Mon YYYY>"` from the Contract Date column. Fix all-caps source names to
  title case (e.g. "BRYON OINES" → "Bryon Oines").

Names render "First Last" (xlsx is already First Last; the CSV is "Last, First" — flip it).

**`topSubmittedWtd` — from WTD New Business Detail CSV:**

1. Filter `Branch == "1156 - Mid-Plains"`.
2. Group by advisor; sum `EstimatedFYC` (already split-adjusted — a 50% split row carries
   that advisor's share, so do NOT re-apply `Case_Split`).
3. Case count = distinct `AppCase_id` per advisor; subtitle = dominant LOB + case count
   (e.g. `"Life · 2 cases"`).
4. Take top 5 by summed FYC.

**`trip` (Leaders Conference tracker) — from YTD FYCC xlsx:**

- Qualification basis: `Total FYCC` per advisor, **ADV contracts only** (Contract column;
  GM/GSM/Affiliates excluded).
- Thresholds prorate by 2026 hire month (Contract Date): hired ≤ Dec 2025 → $135,000;
  Jan $123,750 · Feb $112,500 · Mar $101,250 · Apr $90,000 · May $78,750 · Jun–Dec $67,500.
  President's Circle flat $250,000.
- `qualified` = advisors at/over their threshold, tier labeled (≥250k → President's
  Circle). When the Sales Builder Report PDF is present, cross-check tiers against it
  (official list, usually one week behind — flag mismatches, don't overwrite); when
  absent, skip the cross-check and note it in the summary.
- `closest` = next 10 not-yet-qualified ADVs sorted by amount needed, rows as
  `[name, ytdFycc, personalThreshold]`.
- Update `trip.asOf` to `"computed from Week NN production"`. Keep the footnote verbatim.

**`management` — roster is fixed (carry from prior week: currently Jacob Turner GSM,
Scot Moore GSM, Douglas Tsoka Mgmt, Kathleen Vaske Mgmt).** Refresh each person's `core`,
`inv`, `total` from the YTD FYCC xlsx. Only change the roster if Dustin says so.

**`groups` — from the Producer Group Ranking PDF:** name, Core FYCC, Investments, Total
FYCC for every Mid-Plains group (keep the full list; the template renders top 10 itself).
`members` counts are not in the PDF — carry them from the prior week's object unless a
roster change is provided.

**`recruiting` — from Recruiting Report xlsx, Branch ID 1156 row:** `goal` = Annual Goal,
monthly `counts` = Jan–Dec, `ytd` = Total Recruits, `paceTarget` = YTD Goal rounded to one
decimal, `currentIdx` = the report month, 0-based, derived from the report Friday date (Jan = 0).

### 4. Populate WoW deltas from last week's file

Parse last week's `DASHBOARD_DATA` (from the staged prior HTML) and set in the new object:

- `hero.nbPendingPrior` = last week's `hero.nbPending`
- `hero.submittedPrior` = last week's `hero.submittedWtd`
- `hero.paidPrior` = last week's `hero.paidWtd`
- For each LOB row (match on `label`), plus `core`, `osaic`, `total`:
  `wow = thisWeek.ytd − lastWeek.ytd`
- `meta.baselineWeek: false`

**Append sparkline history:** copy last week's `history` object, then push the new week
onto every series — `weeks` (week number), `pending`, `submitted`, `paid` (this week's
hero values), and each `history.lob` key (`Life`, `Long-Term Care`, `Disability`,
`Annuity`, `Health / Medicare`, `ACA`, `Core`, `Osaic`, `Total` — this week's YTD
figures). Keep only the last 8 entries of each array (drop from the front). Every array
must stay the same length as `weeks` — the sparklines index them in parallel.

Sanity: every `wow` should be ≥ 0 in normal weeks (FYCC is cumulative); investigate any
negative before publishing. `total.wow` should ≈ `core.wow + osaic.wow`.

### 5. Replace the data object and validate

1. Copy last week's HTML to `midplainsdashboardwkNN.html` (new week number). Replace only
   the `const DASHBOARD_DATA = {...};` block — never touch the rendering code below the
   `/* RENDERING */` divider.
2. **Cross-foot checks** before saving:
   - sum of `lob[].ytd` = `core.ytd`; `core.ytd + osaic.ytd` = `total.ytd` = `hero.issuedFycYtd`
   - `total.plan` matches the Distribution Report; `core.plan + osaic.plan = total.plan`
   - Top-5 amounts ≤ corresponding YTD totals; trip `qualified` amounts ≥ thresholds
3. **Validate JS syntax:** extract the `<script>` contents to a temp `.js` file and run
   `node --check` on it. It must pass with no output.
4. **Render check:** open the file headlessly (Playwright/Chromium), confirm no console
   errors and that `#lobTable` and `#tripTable` are populated; screenshot and eyeball it.

### 6. Export dated PDF

Print with headless Chromium/Playwright — `printBackground: true`, `format: "Letter"`,
`scale: 0.62`, margins 0.25–0.3in (verified settings for the v2 template):

```
MidPlains_Dashboard_WkNN_YYYY-MM-DD.pdf     (date = the report Friday)
```

Deliver both the new HTML and the PDF to Dustin (SendUserFile), then commit both to the
MP-Dashboard root on the device.

### 7. Archive inputs

On the device (via device_bash — note `rm` is blocked; use `mv` only):

1. Create `Archive/2026-WkNN/`.
2. `mv` all input files from `Inbox/` into it (six or seven, depending on whether
   Sales Builder shipped that week).
3. `mv` the superseded prior dashboard HTML from the root into it, leaving only the new
   `midplainsdashboardwkNN.html` (and the new PDF) in the root.
4. Confirm Inbox is empty.

## Output summary

When done, report in 3–4 bullets: week label, Total FYC YTD and % of plan, biggest WoW
mover, and anything flagged (missing file, negative WoW, tier mismatch vs Sales Builder).
Internal use only — the footer's non-distribution notice must stay intact.
