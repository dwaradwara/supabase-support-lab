# Runbook - Supabase Auth and RLS troubleshooting

1. Capture the exact Auth status, response code, timestamp and sanitized body.
2. Validate JSON/request serialization before changing Auth configuration.
3. Validate the project publishable key separately from user credentials.
4. Check Auth logs for parsing, credential, provider and user-state errors.
5. Never request or record passwords, refresh tokens or complete JWTs.
6. On successful login, inspect non-secret claims such as `sub`, `role`, `exp`
   and issuer without publishing the token.
7. Test database authorization separately from authentication.
8. Review both grants and RLS policies for the request role.
9. Validate a permitted user, another authenticated user and an anonymous user.
10. Escalate if evidence indicates a platform-wide Auth failure, security risk,
    unexpected token issuance or failures across unrelated projects.
