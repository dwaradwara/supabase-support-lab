# Security

This repository is a support-engineering lab and must not contain real credentials.

Do not commit:

- Supabase secret/service-role keys
- Database passwords
- JWT access or refresh tokens
- User passwords
- `.env` files containing secrets
- Unredacted screenshots that expose credentials

The publishable client key is intentionally designed for client-side use, but it is still omitted from this repository to keep the project clean and reusable.
