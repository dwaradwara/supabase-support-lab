# Runbook — PostgreSQL connectivity

1. Confirm connection method: Direct, Session Pooler or Transaction Pooler.
2. Confirm host, port, database and username.
3. Check IPv4/IPv6 suitability for the chosen method.
4. Validate TLS/SSL behavior.
5. Separate DNS/network errors from authentication errors.
6. After connecting, run `select current_database(), current_user;`.
7. Query an application table to confirm end-to-end access.
