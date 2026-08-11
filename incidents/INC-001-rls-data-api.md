# INC-001 — RLS / Data API access failure

## Symptom
`support_tickets` contained four rows in PostgreSQL, but an anonymous REST request returned an empty array.

## Evidence
- SQL query confirmed four rows existed.
- Data API request returned `[]`.
- RLS was enabled on `public.support_tickets`.

## Investigation
The database itself was healthy and the table contained data. The difference between SQL Editor access and Data API access pointed to authorization rather than missing data.

## Root cause
Row Level Security was enabled, but no SELECT policy allowed the `anon` role to read rows.

## Fix
A temporary SELECT policy was created for the lab:

```sql
create policy "allow public read for support lab"
on public.support_tickets
for select
to anon
using (true);
```

## Recovery validation
The same REST request returned the four expected rows.

## Learning
When PostgreSQL contains data but the Supabase Data API returns no rows, check RLS and the role used by the request before assuming the data is missing.
