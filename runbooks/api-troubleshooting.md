# Runbook — Supabase Data API troubleshooting

1. Capture HTTP status, method, path and response body.
2. Distinguish API-key/JWT/RLS problems from resource-path problems.
3. Read PostgREST error codes and hints.
4. Correlate the request in Unified Logs → API Gateway.
5. Confirm the table/view exists and is exposed through the expected schema.
6. Check RLS and role (`anon` vs `authenticated`).
7. Re-run the exact request after the change and record the recovery status.
