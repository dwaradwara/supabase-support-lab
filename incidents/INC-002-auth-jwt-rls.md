# INC-002 - Authentication, JWT and owner-scoped RLS

## Simulated customer ticket

> Login fails for some attempts. When login succeeds, the Data API result does
> not match what the user expects to see.

## Impact and scope

This scenario crosses four distinct layers: request serialization, project-key
validation, user authentication/JWT issuance and database authorization.

## Initial response

I would capture the exact Auth response, timestamp, project URL and sanitized
request shape. I would not ask for the user's password or full JWT. After login
succeeds, I would validate the token claims and test the Data API separately so
an authentication failure is not confused with an RLS authorization outcome.

## Evidence and isolation

1. Malformed request body: Auth logs showed a JSON parsing failure.
2. Invalid project key input: request failed before credential validation.
3. Correct request with the wrong password: `invalid_credentials`.
4. Correct request and credentials: access token issued with 3600-second expiry.
5. Authenticated Data API request: authorization behavior controlled by RLS.

## Root causes

The failures came from different layers rather than one Supabase outage. The
original lab then used `to authenticated using (true)`, which proved the role
transition but allowed every authenticated user to read every ticket. Version 2
removes that unsafe final state.

## Secure final policy

```sql
create policy "users read their own tickets"
on public.support_tickets
for select
to authenticated
using ((select auth.uid()) = owner_id);
```

## Validation requirements

- Missing/expired JWT does not expose rows.
- User A sees only User A tickets.
- User B sees only User B tickets.
- User A cannot read User B tickets.
- Full JWTs, API secrets and passwords are absent from evidence.

The repository contains a synthetic-claim SQL validation in
`sql/rls-validation.sql`. A real Auth API validation must also be rerun with the
hosted project's test users before the incident is marked fully validated.

## Customer-facing resolution

The failures occurred at separate stages. We first corrected the JSON and
project-key inputs, then validated the user credentials and JWT. After
authentication succeeded, we corrected the database policy so the signed-in
user can see only rows owned by that user. This avoids the unsafe alternative of
granting all authenticated users access to all customer tickets.

## Learning

Treat Auth request parsing, project-key validation, credential verification,
JWT issuance, table grants and RLS as distinct checkpoints. State which layer
the evidence supports instead of labeling every failure as an Auth problem.
