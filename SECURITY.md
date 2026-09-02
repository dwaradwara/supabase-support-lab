# Security

This repository is a support-engineering lab and must not contain real
credentials or customer data.

Do not commit:

- Supabase secret/service-role keys
- database passwords
- complete JWT access or refresh tokens
- user passwords
- `.env` files containing secrets
- real customer identifiers or personal data
- unredacted screenshots containing credentials, private URLs or unrelated
  browser/desktop context

The publishable client key is designed for client-side use, but its value is
still omitted so the project stays reusable and evidence remains minimal.

## Evidence rules

- Prefer raw sanitized text for logs and SQL plans.
- Crop screenshots to the relevant technical evidence.
- Exclude ChatGPT conversation URLs, personal tabs, notifications and taskbars.
- Preserve useful timestamps and request IDs only when they do not expose data.
- Record the HTTP transport status separately from status fields inside a JSON
  error payload.
- Validate both permitted and denied authorization paths.

If a secret is committed, remove it from the current tree, rotate it immediately
and assess whether Git history must be rewritten. Deleting the visible file is
not a substitute for rotating a credential.
