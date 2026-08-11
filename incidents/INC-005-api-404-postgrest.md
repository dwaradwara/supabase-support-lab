# INC-005 — Data API 404 / PostgREST resource error

## Symptom
A REST request returned HTTP 404.

## Evidence
The failing request used a misspelled resource:

`/rest/v1/support_ticketssss?select=*`

The response contained:
- HTTP 404
- PostgREST error `PGRST205`
- a hint suggesting `public.support_tickets`

The same request was visible in Supabase Unified Logs → API Gateway as a 404 GET.

## Root cause
The endpoint referenced a table/resource that did not exist in the PostgREST schema cache.

## Fix
Corrected the endpoint to:

`/rest/v1/support_tickets?select=*`

## Recovery validation
The corrected request returned HTTP 200. Because anonymous SELECT access was intentionally blocked by RLS, a successful anonymous response could still contain an empty array.

## Evidence
- [404 response](../evidence/screenshots/INC-005-pgrst205-404.png)
- [API Gateway correlation](../evidence/screenshots/INC-005-api-gateway-404.png)

## Learning
An HTTP 404 from Supabase Data API does not automatically mean the platform is down. Read the PostgREST code/message and correlate it with API Gateway logs.
