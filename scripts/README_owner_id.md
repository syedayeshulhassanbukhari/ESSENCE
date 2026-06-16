What this does
----------------
Adds an `owner_id` column to the `exchange_listings` table and creates an index. Legacy rows are intentionally left NULL per your selected option.

How to run
----------
Option A — Supabase SQL editor (recommended):
1. Open your Supabase project → Database → SQL Editor.
2. Copy the contents of `scripts/add_owner_id.sql` and run it.

Option B — psql (local or remote Postgres connection):
1. Ensure you have `psql` installed.
2. Run (replace with your Postgres connection string or ensure $DATABASE_URL is set):

```powershell
$env:DATABASE_URL = "postgres://<user>:<pass>@<host>:5432/<db>"
psql "$env:DATABASE_URL" -f scripts/add_owner_id.sql
```

Option C — Supabase CLI:
If you prefer the Supabase CLI, you can paste the SQL into the SQL editor in the web console or use the CLI to run SQL commands if configured with a DB connection.

Notes
-----
- This script is idempotent: running it multiple times is safe.
- Backfill: we left legacy rows NULL as requested. If later you want to set a default UID for legacy rows, run:

```sql
UPDATE exchange_listings
SET owner_id = '<FIREBASE_UID>'
WHERE owner_id IS NULL;
```

Replace `<FIREBASE_UID>` with the chosen Firebase UID.
