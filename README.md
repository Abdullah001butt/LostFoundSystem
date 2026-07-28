# Lost & Found Campus System

A relational database for managing lost and found items on a college campus — students can report lost or found items, the system automatically suggests matches between them, students can submit claim requests, and admins approve or reject those claims.

Built with **Microsoft SQL Server (T-SQL)** as a DBMS course project demonstrating **Joins**, **Triggers**, and **Stored Procedures**.

📄 Full write-up: [`DBMS_Project_Report.pdf`](DBMS_Project_Report.pdf)
🗺️ Schema diagram: [`ER_Diagram.pdf`](ER_Diagram.pdf)

---

## Features

| Feature | Description |
|---|---|
| Report Lost Item | Student records an item they lost — title, category, description, location, date |
| Report Found Item | Student/staff records an item they found |
| Match Similar Items | Database auto-suggests Lost↔Found pairs by category, location, and date window |
| Claim Requests | Student requests ownership of a found item with proof details |
| Admin Approval | Admin approves/rejects claims; approval finalizes the hand-over |

## Tech Stack

- **Database:** Microsoft SQL Server (developed/tested on SQL Server 2022 / SSMS)
- **Language:** T-SQL

## Schema Overview

Five tables: `Users`, `Items` (unified Lost/Found), `Matches`, `ClaimRequests`, `AuditLog`.
See [`ER_Diagram.pdf`](ER_Diagram.pdf) for the full entity-relationship diagram with columns, keys, and cardinality.

---

## Prerequisites

- **SQL Server** (Express edition is fine) — [download here](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
- **SQL Server Management Studio (SSMS)** — [download here](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
- A login with permission to `CREATE DATABASE` on your SQL Server instance

## How to Run

Run the scripts in order, starting with **resetdb.sql**, every time — even on a fresh machine. This guarantees a clean database no matter what state it was left in by a previous run.

`resetdb.sql → 01 → 02 → 03 → 04 → 05 → 06`

### 1. Open the project in SSMS

Clone or download this repo, then open each `.sql` file in SSMS (`File → Open → File...`).

```bash
git clone https://github.com/Abdullah001butt/LostFoundSystem.git
```
### 2. Reset the database — `resetdb.sql`

Drops the LostFoundSystem database if it already exists, so you always start from a clean slate. Safe to run even if the database doesn't exist yet — it checks first.

- Open `resetdb.sql`
- Ctrl+A → Execute (F5)
- Close any other query tabs that have LostFoundSystem selected as their active database before running this — SQL Server won't drop a database that has another active connection

> Tip: Run this before every run-through, not just the first time. Re-running 01_schema.sql against a database that already exists will fail with "already exists" errors on every table — resetdb.sql avoids that entirely.

### 3. Create the schema — `01_schema.sql`

Creates the `LostFoundSystem` database and all 5 tables with primary keys, foreign keys, and constraints.

1. Open `01_schema.sql`
2. Press **Ctrl+A** to select the entire file, then **Execute** (F5)
3. Confirm success: the database dropdown in the toolbar should now show `LostFoundSystem`, and the Messages pane should say `Commands completed successfully`

> **Tip:** If you only select part of the script instead of the whole file, later `CREATE TABLE` statements may not run. Always select the full file before executing.

### 4. Load sample data — `02_sample_data.sql`

Inserts 5 sample users and 6 sample items (3 lost, 3 found).

- Make sure the database dropdown shows `LostFoundSystem`, then Ctrl+A → Execute

### 5. Run the join queries — `03_joins.sql`

Six example queries demonstrating `JOIN`, `LEFT JOIN`, and aggregation across the schema.

- Ctrl+A → Execute, and check the Results pane — you should see 6 result sets

### 6. Create the triggers — `04_triggers.sql`

Creates two triggers on `ClaimRequests`:

- `trg_ClaimRequest_Insert` — blocks a user from claiming an item they reported themselves; otherwise marks the item `ClaimPending` and logs the claim
- `trg_ClaimRequest_Approved` — on `Approved`, marks the item `Claimed` and auto-rejects other pending claims on the same item; on `Rejected`, reverts the item back to `Open` (unless another claim is still pending on it)

> The self-claim check used to live in its own trigger (`trg_ClaimRequest_PreventSelfClaim`). It's now merged into `trg_ClaimRequest_Insert` so it's guaranteed to run before the status update, instead of relying on SQL Server's undefined ordering between two separate `AFTER INSERT` triggers. If an old copy of `trg_ClaimRequest_PreventSelfClaim` exists from a previous run, this script drops it automatically.

- Ctrl+A → Execute

### 7. Create the stored procedures — `05_procedures.sql`

Creates four procedures:

| Procedure | Purpose |
|---|---|
| `sp_ReportItem` | Insert a new lost/found report |
| `sp_MatchItems` | Auto-match open Lost items to open Found items |
| `sp_ReviewClaim` | Admin approves/rejects a claim (transactional); refuses to act on a claim that isn't currently `Pending` |
| `sp_GetUserReports` | Get all reports submitted by a given user |

- Ctrl+A → Execute

### 8. Run the end-to-end demo — `06_demo.sql`

Exercises the whole system in sequence, including the failure paths on purpose:

- Runs the matcher and shows suggested matches
- Submits a claim, watches the trigger flip the item to `ClaimPending`
- Approves the claim via `sp_ReviewClaim`, watches the item flip to `Claimed`
- Submits a second claim on a different item, then rejects it — watches the item revert from `ClaimPending` back to `Open`
- Tries to re-review that same (already-rejected) claim — expected to fail with `ClaimID was not found or is no longer Pending`, proving the re-review guard works
- Tries to claim an item as the same user who reported it — expected to fail with Y`ou cannot claim an item you reported yourself`, proving the self-claim trigger works
- Reads back a user's report history and the full audit trail

> Steps 5 and 6 are supposed to raise errors — that's the demo proving the fixes work, not something going wrong. Don't be alarmed by the red error text in those two spots.

- Ctrl+A → Execute
- Check each result grid in order — you should see suggested matches, both status flips described above, the two intentional errors, and the full `AuditLog` at the end

---

## Project Structure

```
LostFoundSystem/
├── resetdb.sql              # Drops the database cleanly before each run
├── 01_schema.sql            # Database + table creation (DDL)
├── 02_sample_data.sql       # Sample seed data
├── 03_joins.sql             # JOIN query examples
├── 04_triggers.sql          # Trigger definitions
├── 05_procedures.sql        # Stored procedure definitions
├── 06_demo.sql              # End-to-end demo / test script
├── ER_Diagram.pdf           # Entity-relationship diagram
├── DBMS_Project_Report.pdf  # Full project report
└── README.md
```

## Troubleshooting

**"Database 'LostFoundSystem' already exists" / "There is already an object named 'X'"**
`01_schema.sql` was run against a database that already exists from a previous run. Run `resetdb.sql` first, then re-run `01_schema.sql`. Do this before every run-through, not just the first one.

**"Cannot drop database... because it is currently in use" or a permissions error when running `resetdb.sql`**
Another query tab or connection still has `LostFoundSystem` selected. Switch every other open tab to `master` (or close them), then re-run `resetdb.sql`. If it still fails, check that you are connected to the same SQL Server instance the database was originally created on.

**"ClaimID X was not found or is no longer Pending" while running `06_demo.sql`**
This means `06_demo.sql` (or parts of it) already ran once against the current database, so the claim IDs it expects do not line up with fresh data. Run `resetdb.sql`, then re-run `01` through `06` in order without skipping or re-running any script twice.

**"Invalid object name 'X'" when running a later script**
The schema script didn't fully complete. Run this to check which tables actually exist:

```sql
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES ORDER BY TABLE_NAME;
```
You should see all 5: `AuditLog`, `ClaimRequests`, `Items`, `Matches`, `Users`. If any are missing, re-run `01_schema.sql` in full (Ctrl+A → Execute) — statements for tables that already exist will safely no-op with an "already exists" message, and the rest will run.

**"Database 'LostFoundSystem' does not exist"**
You likely ran only part of the script. Select the whole file (Ctrl+A) and re-execute, or run just the `CREATE DATABASE LostFoundSystem; GO` block first, refresh Object Explorer, then run the rest.

**Toolbar shows `master` instead of `LostFoundSystem`**
Select `LostFoundSystem` from the database dropdown at the top of the SSMS toolbar before running scripts 02–06.

## Team

| Name | Role |
|---|---|
| Nabia Sajid (BSAI-II) | Group Leader |
| Muhammad Abdullah (BSCS-II) | Member |
| Maryam Muazzam (BSCS-II) | Member |
| Sathya Narayan (BSAI-II) | Member |

## License

Academic project — for coursework submission.
