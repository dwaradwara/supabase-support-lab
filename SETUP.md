# Reproducing the Version 2 lab

## Safety

Use a dedicated disposable Supabase project. `sql/00-reset.sql` drops the lab
tables and must never be run against a production or shared database.

## Run order

1. Review and run `sql/00-reset.sql` only in the disposable lab.
2. Run `sql/schema.sql`.
3. Run `sql/seed.sql`.
4. Run `sql/rls-policies.sql`.
5. Run `sql/rls-validation.sql` and save the actual output.
6. Run incident reproduction files individually as documented.

## Synthetic identities

The SQL-only RLS tests use two synthetic UUID claims. This avoids modifying the
protected `auth.users` schema and keeps the policy test deterministic. For an
end-to-end Auth API test, create test users through Supabase Auth and insert lab
rows whose `owner_id` matches each test user's JWT `sub` claim.

## Evidence status

Files marked pending are authored but not yet validated against the hosted
project. Do not replace pending labels with successful claims until the commands
have actually been executed and the output reviewed.
