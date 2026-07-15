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

Run the scripts **in order**. Each one builds on the previous.

### 1. Open the project in SSMS

Clone or download this repo, then open each `.sql` file in SSMS (`File → Open → File...`).

```bash
git clone https://github.com/Abdullah001butt/LostFoundSystem.git
```

### 2. Create the schema — `01_schema.sql`

Creates the `LostFoundSystem` database and all 5 tables with primary keys, foreign keys, and constraints.

1. Open `01_schema.sql`
2. Press **Ctrl+A** to select the entire file, then **Execute** (F5)
3. Confirm success: the database dropdown in the toolbar should now show `LostFoundSystem`, and the Messages pane should say `Commands completed successfully`

> **Tip:** If you only select part of the script instead of the whole file, later `CREATE TABLE` statements may not run. Always select the full file before executing.

### 3. Load sample data — `02_sample_data.sql`

Inserts 5 sample users and 6 sample items (3 lost, 3 found).

- Make sure the database dropdown shows `LostFoundSystem`, then Ctrl+A → Execute

### 4. Run the join queries — `03_joins.sql`

Six example queries demonstrating `JOIN`, `LEFT JOIN`, and aggregation across the schema.

- Ctrl+A → Execute, and check the Results pane — you should see 6 result sets

### 5. Create the triggers — `04_triggers.sql`

Creates three triggers on `ClaimRequests`:

- `trg_ClaimRequest_Insert` — marks an item `ClaimPending` when a claim is submitted
- `trg_ClaimRequest_Approved` — marks an item `Claimed` when a claim is approved, and auto-rejects other pending claims on the same item
- `trg_ClaimRequest_PreventSelfClaim` — blocks a user from claiming an item they reported themselves

- Ctrl+A → Execute

### 6. Create the stored procedures — `05_procedures.sql`

Creates four procedures:

| Procedure | Purpose |
|---|---|
| `sp_ReportItem` | Insert a new lost/found report |
| `sp_MatchItems` | Auto-match open Lost items to open Found items |
| `sp_ReviewClaim` | Admin approves/rejects a claim (transactional) |
| `sp_GetUserReports` | Get all reports submitted by a given user |

- Ctrl+A → Execute

### 7. Run the end-to-end demo — `06_demo.sql`

Exercises the whole system in sequence: runs the matcher, submits a claim, watches the trigger update item status, approves the claim via the procedure, watches the second trigger fire, and reads back the audit trail.

- Ctrl+A → Execute
- Check each result grid in order — you should see:
  1. Suggested matches in the `Matches` table
  2. The claimed item's status flip from `Open` → `ClaimPending` → `Claimed`
  3. Two entries in `AuditLog` (one `INSERT`, one `UPDATE`)

---

## Project Structure

```
LostFoundSystem/
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
| Nabia | Group Leader |
| Muhammad Abdullah | Member |
| Maryam | Member |
| Sathya Narayan | Member |

## License

Academic project — for coursework submission.
