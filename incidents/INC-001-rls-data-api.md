# INC-001 - RLS / Data API visibility failure

## Simulated customer ticket

> The `support_tickets` table contains data in the SQL Editor, but the client
> request succeeds with HTTP 200 and returns an empty array. No error is shown.

## Impact and scope

Data visibility is blocked for the affected client role. The database remains
available, and there is no evidence of data loss.

## Initial response

I understand the records are visible in the SQL Editor but not in the client.
I would first confirm the client role, JWT state, project URL, exact request and
whether this affects anonymous users, authenticated users or both. The SQL
Editor and client may use different database roles, so I will compare those
execution contexts before changing any policy.

## Evidence

- SQL query confirmed that four seed rows existed.
- The anonymous Data API request returned `[]` with HTTP 200.
- RLS was enabled on `public.support_tickets`.
- The `anon` role had the table-level SELECT grant but no matching SELECT policy.

## Hypotheses considered

| Hypothesis | Test | Result |
|---|---|---|
| Data was missing | Queried the table directly | Rejected: rows existed |
| Wrong resource path | Compared the endpoint with the table/schema | Rejected: resource was correct |
| Platform outage | Confirmed the request succeeded with HTTP 200 | Rejected |
| RLS filtered the rows | Compared role and active policies | Supported |

## Root cause

RLS was enabled, but no SELECT policy allowed the request role to see rows.
For SELECT operations, RLS can return a successful response with zero visible
rows rather than an authorization error.

## Controlled lab reproduction

The original lab temporarily created an unrestricted anonymous policy to prove
the diagnosis. That policy is not retained in the secure final state because it
would expose every row to unauthenticated callers.

## Secure final fix

The Version 2 schema uses an `owner_id` column and an authenticated SELECT policy:

```sql
using ((select auth.uid()) = owner_id)
```

See `sql/rls-policies.sql`.

## Validation

- Anonymous role: zero visible rows.
- User A: only User A rows.
- User B: only User B rows.
- Unrelated authenticated user: zero rows.
- Cross-user visibility count: zero.

Run `sql/rls-validation.sql` and record the actual output before marking this
Version 2 incident as validated.

## Customer-facing resolution

The client and SQL Editor were using different database roles. The records were
present, but Row Level Security filtered them from the client role. We replaced
the temporary broad policy with an owner-scoped policy and verified that each
test user can see only their own tickets while anonymous and unrelated users
remain blocked.

## What would differ in production

- Do not enable a broad `using (true)` policy as a shortcut.
- Review table grants as well as policies.
- Use a trusted identity relationship, normally referencing `auth.users` or a
  protected profile/membership table.
- Test allow and deny behavior before deploying the migration.
