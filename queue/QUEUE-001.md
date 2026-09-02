# QUEUE-001 — Competing support tickets

> **Simulation only:** These are fictional support tickets created to practice queue triage. They are not real customer incidents and do not demonstrate production ticket volume or SLA performance.

## Operating constraints

- You are the only first-line technical support engineer available for the next 60 minutes.
- You can begin one investigation immediately and acknowledge the other tickets with a useful next step.
- Do not ask customers to share passwords, JWTs, service-role keys, or full credential-bearing connection strings.
- Severity and priority are provisional until scope, business impact, and reproducibility are confirmed.

## Initial queue

### TKT-101 — Production API returning 500 for all requests

- **Customer:** A paid SaaS application
- **Reported symptom:** “Our backend started returning HTTP 500 for every request to the project API about 10 minutes ago.”
- **Scope currently known:** The customer reports that both their web application and worker process are affected. No successful request has been provided.
- **Business impact:** Customer says checkout and account pages are failing.
- **Evidence provided:** One redacted request path, timestamp in UTC, and a screenshot showing HTTP 500.
- **Unknowns:** Whether the failure is project-wide, endpoint-specific, caused by the client, or related to a recent customer deployment.

### TKT-102 — One user cannot log in

- **Customer:** Internal team application
- **Reported symptom:** “One employee gets ‘invalid login credentials’; everyone else can log in.”
- **Scope currently known:** One user, one email/password login flow.
- **Business impact:** The employee is blocked, but the application remains available to other users.
- **Evidence provided:** Redacted timestamp and the Auth error string.
- **Unknowns:** Whether the password is wrong, the account is unconfirmed/disabled, the client targets the correct project, or a policy changed.

### TKT-103 — Private Storage upload denied for all users

- **Customer:** Document-processing application
- **Reported symptom:** “Every authenticated user now gets a 403 when uploading a PDF to our private bucket.”
- **Scope currently known:** Customer tested with three accounts. Downloads of existing objects reportedly still work.
- **Business impact:** New document processing is stopped; existing documents remain accessible.
- **Evidence provided:** Redacted bucket name, HTTP 403, and `new row violates row-level security policy`.
- **Unknowns:** Whether a Storage policy, object path, file type, client release, or project setting changed.

### TKT-104 — One query became slow after a data increase

- **Customer:** Analytics dashboard
- **Reported symptom:** “The customer search screen takes 8–12 seconds now; it used to be fast.”
- **Scope currently known:** One search endpoint appears slow. The customer recently imported a large dataset.
- **Business impact:** Degraded performance, but requests eventually succeed.
- **Evidence provided:** Query shape with values redacted and approximate timing.
- **Unknowns:** Query plan, row count, indexes, concurrency, database resource pressure, and whether all customers are affected.

### TKT-105 — REST endpoint returns 404 after a deployment

- **Customer:** Developer building an internal integration
- **Reported symptom:** “Our REST call returns 404 after yesterday’s deployment.”
- **Scope currently known:** One endpoint; no evidence yet that other endpoints fail.
- **Business impact:** One integration workflow is blocked.
- **Evidence provided:** HTTP 404 and a request URL with the project host redacted.
- **Unknowns:** Resource spelling, schema exposure, deployment route, API version, and authorization state.

### TKT-106 — External database connection rejected

- **Customer:** Developer running a reporting job
- **Reported symptom:** “Our scheduled `psql` job says password authentication failed.”
- **Scope currently known:** One external job; the customer has not confirmed whether dashboard/database access is also affected.
- **Business impact:** Reporting refresh is delayed; the application itself is reportedly operating normally.
- **Evidence provided:** Redacted `psql` error, approximate timestamp, and statement that the job configuration was recently edited.
- **Unknowns:** Host, port, database, username, pooler/direct connection choice, TLS mode, and whether the secret was changed or copied incorrectly.

## Candidate response format

For each ticket, record:

- Provisional severity and priority
- Why it belongs at that position in the queue
- First diagnostic action
- First customer-facing update
- Escalation decision and trigger

Do not write a final root cause from this initial information. The exercise is specifically testing disciplined triage under uncertainty.
