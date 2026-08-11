# INC-002 — Authentication, JWT and authenticated RLS

## Symptom
Authentication requests failed at different stages and authenticated access to the Data API had to be validated.

## Evidence
Three separate failures were reproduced:
1. Malformed request body: Auth logs showed JSON parsing failure.
2. Invalid API key: request was rejected before login validation.
3. Valid request with wrong password: `invalid_credentials`.

## Investigation
Each failure was isolated by moving one layer at a time:
- request serialization
- project API key
- user credentials
- JWT issuance
- authenticated RLS behavior

## Root cause
The failures were caused by different request-layer and credential-layer issues rather than one platform outage.

## Fix
- Generated JSON using PowerShell object serialization.
- Corrected the publishable key variable.
- Used the correct test-user credentials.
- Replaced the temporary anonymous SELECT policy with an authenticated-only policy.

```sql
create policy "authenticated users can read tickets"
on public.support_tickets
for select
to authenticated
using (true);
```

## Recovery validation
- Login returned a valid access token.
- Token expiry reported 3600 seconds.
- Authenticated request returned the four tickets.
- The same request without the JWT returned zero rows.

## Learning
Treat Supabase Auth, API-key validation, JWT issuance and PostgreSQL RLS as separate layers during troubleshooting.
