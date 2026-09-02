# Supabase support architecture

This is a simplified support-troubleshooting view of the request path. Exact behavior depends on the client, endpoint, policies, and project configuration.

```mermaid
flowchart LR
    C[Client\nweb, mobile, curl, psql]
    A[Supabase Auth\nlogin / session]
    J[JWT\nrequest identity and role]
    G[Data API / PostgREST\nREST requests]
    S[Storage API\nobject operations]
    D[(PostgreSQL\ntables and storage.objects)]
    R{RLS policies\nallow or deny}
    L[Logs and evidence\nstatus, IDs, timestamps]

    C -->|credentials or public key| A
    A -->|access token| J
    C -->|Bearer JWT| G
    C -->|Bearer JWT| S
    J --> G
    J --> S
    G --> R
    S --> R
    R -->|authorized query or mutation| D
    R -->|403 / empty result| L
    G --> L
    S --> L
```

## How to use the diagram during triage

- Login failure: start at the client/Auth boundary; do not begin with PostgreSQL RLS.
- Empty Data API response: compare database rows with the request JWT role and the applicable table policy.
- Storage 403: inspect bucket operation, object path, session role, and `storage.objects` policy.
- REST 404: verify route/resource resolution before changing authorization policies.
- `psql` authentication failure: inspect endpoint, username, database, TLS, and password stage separately from Data API Auth.
