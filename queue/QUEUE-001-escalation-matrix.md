# QUEUE-001 — Escalation matrix

> **Simulation only:** This matrix is a practice framework. Actual routing, severity names, response targets, and on-call ownership depend on the employer’s internal process.

## Escalation rules

Escalate when the evidence shows broader scope, a platform-level possibility, data/security risk, or a change that first-line support should not make alone. Escalation is not a substitute for collecting a useful handoff.

| Ticket | Initial owner | Escalate to | Escalate when | Handoff must include | Do not do first |
|---|---|---|---|---|---|
| TKT-101 | Support + incident coordinator | Platform/API on-call and incident lead | Controlled requests fail across multiple routes, customer services, or projects; or impact includes checkout/account access | UTC start time, scope, redacted routes, status/body, correlation IDs, recent customer changes, successful/failed control request, logs already checked | Tell the customer to restart everything, change RLS, rotate keys, or declare a platform outage without evidence |
| TKT-103 | Support | Storage/Auth/RLS specialist | Authenticated users still fail after role, path, policy, and client checks; or existing-object reads also fail | Bucket privacy, redacted object path, user role, exact 403, policy names/actions, client version, anonymous vs authenticated comparison, timestamps | Make the bucket public, use a service-role key in the client, or disable RLS |
| TKT-104 | Support + database specialist | Database performance/on-call | Query timeouts/errors appear, resource pressure is suspected, many endpoints degrade, or an index/query change needs production review | Redacted query shape, plan before/after if available, row estimate/count, buffers/timing, affected scope, concurrency/resource observations, rollback plan | Add an index blindly, run heavy diagnostics repeatedly, or promise a latency reduction not measured |
| TKT-105 | Support | API/PostgREST specialist | Multiple known-good routes return 404, the resource is correctly spelled/exposed but still unresolved, or a schema/cache issue is suspected | Method, redacted path, status/body, UTC time, known-good comparison, resource/schema name, deployment change, auth state, correlation ID | Change database policies, restart services, or treat 404 as an authorization failure automatically |
| TKT-102 | Support | Auth specialist or account administrator | Multiple users fail, account state is abnormal, confirmation/recovery is broken, or an account-security concern appears | Redacted user identifier, UTC time, exact error, project/client target, confirmation/account state, password-reset result, scope comparison | Ask for or reset a password without authorization, request a JWT, or disable security controls |
| TKT-106 | Support | Database connectivity/on-call or security owner | Multiple jobs fail, the application also loses connectivity, TLS/endpoint behavior is inconsistent, or credential exposure is suspected | UTC time, redacted error, connection type, non-secret host category/port/database, username class, pooler/direct choice, TLS mode, recent config change | Ask the customer to paste the password/full connection string, rotate credentials blindly, or switch endpoints without confirming target |

## Escalation packet template

```text
Ticket:
Customer impact and current scope:
Provisional severity/priority:
First known failure time (UTC):
Exact redacted symptom and status:
Reproduction/control test:
What is confirmed:
What remains unknown:
Recent changes:
Diagnostics already performed:
Security or data-integrity concerns:
Requested decision or specialist action:
Customer communication already sent:
Next update time/condition:
```

## Escalation quality standard

A good escalation lets the receiving engineer act without repeating unsafe or irrelevant tests. It contains facts, timestamps, scope, reproduction status, and a specific question. It does not contain credentials, unredacted customer data, speculative blame, or a vague request to “look into it.”
