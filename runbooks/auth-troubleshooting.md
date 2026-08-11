# Runbook — Supabase Auth troubleshooting

1. Confirm the request body is valid JSON.
2. Validate the project publishable key separately from user credentials.
3. Check Auth logs for parsing, credential and user-state errors.
4. Avoid printing JWTs or passwords into screenshots/logs.
5. On successful login, validate token presence and expiry without exposing the token.
6. Test authenticated authorization separately through an RLS-protected resource.
