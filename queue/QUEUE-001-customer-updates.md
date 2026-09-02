# QUEUE-001 — Initial customer updates

> **Simulation only:** These messages are practice drafts based on the fictional queue. They are not messages sent to real customers and do not represent production SLA commitments.

## TKT-101 — Production API returning 500

**Subject:** Investigating elevated API errors affecting your application

Hi,

I understand that your web application and worker are currently receiving HTTP 500 responses, affecting checkout and account pages. I’m treating this as a high-priority availability issue and am checking whether the failure is project-wide or limited to a route, client release, or recent deployment.

Please reply with the UTC timestamps, redacted endpoint paths, response status/body, and any request or correlation IDs. Please do not send API secrets, passwords, JWTs, or full credential-bearing connection strings. I’ll update you after the initial scope check or sooner if the impact changes.

## TKT-103 — Authenticated Storage upload denied

**Subject:** Investigating 403 errors on authenticated document uploads

Hi,

I understand that three authenticated users are receiving HTTP 403 when uploading PDFs to the private bucket, while existing downloads still work. I’m treating new document processing as a high-priority blocked workflow and will compare the failing object path, authenticated role, policy evaluation, and any recent policy or client changes.

Please provide the UTC timestamp, redacted bucket/object path, response status/message, affected client version, and whether all file types and folders fail. Please do not send passwords, access tokens, service-role keys, or private files. I’ll first validate the smallest safe reproduction and will not recommend weakening the bucket or disabling RLS as a workaround.

## TKT-104 — Slow customer search

**Subject:** Investigating increased search latency after the data import

Hi,

I understand that customer searches now take approximately 8–12 seconds after the recent data import, although requests eventually complete. I’m checking the query plan, row growth, indexes, concurrency, and whether the delay affects all searches or only particular values.

Please provide a redacted query shape, approximate row count, UTC timestamps, affected endpoint, and whether timeouts or errors also occur. Please do not send customer records or credentials. I’ll assess the lowest-risk performance improvement and its write/storage trade-offs before recommending a change.

## TKT-105 — REST endpoint returns 404

**Subject:** Checking the REST route and resource name returning 404

Hi,

I understand that one REST integration endpoint began returning HTTP 404 after yesterday’s deployment. I’m first verifying the exact project route, resource spelling, API version, and whether other endpoints are working; a 404 can indicate routing or resource resolution and does not by itself prove an RLS problem.

Please provide the redacted request path, HTTP method, UTC timestamp, response body, and whether the same client can reach another known-good endpoint. Please do not send API keys or tokens. I’ll update you once the failing layer is isolated.

## TKT-102 — One user cannot log in

**Subject:** Investigating an account-specific login failure

Hi,

I understand that one employee receives `invalid login credentials` while other users can log in. Because the scope is currently limited to one account, I’m checking the project/client target, account state, confirmation status, and whether the password was recently changed before considering any broader Auth issue.

Please provide the UTC timestamp, redacted client/project context, and whether the user can complete a password-reset flow. Please do not send the password, JWT, recovery token, or full API key. If more users begin failing, please let us know immediately so we can re-prioritize the incident.

## TKT-106 — External database connection rejected

**Subject:** Checking the reporting job’s database connection configuration

Hi,

I understand that one scheduled `psql` reporting job is receiving a password authentication failure while the application remains operational. I’m checking the intended host, port, database, username, pooler/direct connection choice, TLS mode, and the recent configuration edit. This error confirms an authentication-stage failure only; it does not yet establish a platform outage.

Please provide the redacted error, UTC timestamp, and non-secret connection attributes such as host category, port, database name if safe, and whether the job is using the intended pooler. Please do not send the password or a complete credential-bearing connection string. I’ll update you after the target and credential path are verified.

## Communication rules demonstrated

- Acknowledge the customer’s impact before discussing implementation details.
- State the investigation boundary and the next concrete check.
- Ask for reproducible, redacted evidence rather than secrets.
- Avoid declaring a root cause before validation.
- Give the customer a trigger for re-contacting support if scope worsens.
