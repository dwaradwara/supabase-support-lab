# INC-007 — External PostgreSQL connection / credential failure

This is a self-directed simulated incident in a hosted Supabase project. It is not a production customer case.

## Incident metadata

- **Incident ID:** `INC-007`
- **Title:** External `psql` connection failed database authentication
- **Status:** Resolved in the lab
- **Severity:** Provisional S2 / moderate operational impact
- **Priority:** P2 while the connection method and failure layer were being confirmed
- **Affected area:** PostgreSQL connectivity / Session Pooler / credentials / TLS
- **Customer impact:** An external support or operational tool could not connect to the project database. The failure blocked the diagnostic session but did not establish database unavailability or data loss.
- **Detection or report:** Simulated report that an external `psql` connection could not authenticate.

## Customer symptom

An external `psql` connection to Supabase PostgreSQL failed with a password authentication error.

The important first distinction is whether the client can reach the host and port. DNS, network, TLS, pooler selection, username/database, and password failures require different actions.

## Initial assessment

- **What is confirmed:** The client reached the PostgreSQL endpoint and returned a password authentication failure.
- **What is not yet confirmed:** Whether the host, port, database, username, connection method, TLS settings, and password correspond to the intended project.
- **Initial assumptions:** The Session Pooler was the intended connection method for the external environment and the connection string targeted the correct project. These assumptions required verification.
- **Immediate safety concern:** Never place database passwords or connection strings containing credentials in source files, screenshots, tickets, or chat. Do not rotate credentials or expose a direct connection string without confirming scope.
- **First customer update:** Confirm that the endpoint is reachable but authentication is failing, ask for a redacted connection configuration and timestamp, and explain that credentials should not be shared in the ticket.

## Triage and prioritization

- **Why this priority was selected:** The connection blocked one diagnostic path, but the error indicated a credential-layer failure rather than a confirmed service outage. It was treated as P2 provisionally.
- **Who or what may be affected:** The external tool or operator using the connection details. Other application traffic may remain healthy; scope must be checked.
- **What I would investigate first:** Connection method, host, port, database, username, TLS mode, client version, and the exact error category.
- **What I would defer:** Password rotation, firewall changes, database restart, switching poolers blindly, and sharing secret connection details.
- **Escalation trigger:** Escalate if the correct credentials fail across clients, DNS/network/TLS errors appear, the project database is unavailable, credentials may be compromised, or the connection method is incompatible with the workload.

## Investigation

1. **Check:** Classify the error before changing configuration.
   - **Reason:** Authentication errors differ from DNS, timeout, refused-connection, and TLS failures.
   - **Result:** `psql` returned password authentication failure, indicating the endpoint was reached and the failure occurred during database authentication.
2. **Check:** Confirm the intended connection method.
   - **Reason:** Direct, Session Pooler, and Transaction Pooler endpoints have different host/port and workload characteristics.
   - **Result:** The lab used the Supabase Session Pooler from Windows PowerShell.
3. **Check:** Verify host, port, database, username, and TLS settings without exposing the password.
   - **Reason:** A correct password cannot work against the wrong project or database identity.
   - **Result:** The same target and TLS configuration were retained for the controlled retry.
4. **Check:** Retry with the correct database password through the same endpoint.
   - **Reason:** Keep one variable changed so the recovery result isolates the credential problem.
   - **Result:** The connection succeeded over TLS.
5. **Check:** Validate session identity and application access.
   - **Reason:** A successful TCP/authentication handshake alone does not prove the expected database or permissions were reached.
   - **Result:** `current_database()`, `current_user`, and a count query against `public.support_tickets` returned successfully.

## Evidence

- Environment: Windows PowerShell and PostgreSQL `psql` 16.14.
- Connection method: Supabase Session Pooler.
- Transport: TLS.
- Initial failure: password authentication failure from `psql`.
- Recovery: same target retried with the correct database password and connected successfully.
- Post-connection checks included `select current_database(), current_user;` and `select count(*) from public.support_tickets;`.
- The application table count returned 50,004 rows in the lab capture.
- Evidence screenshot: [`INC-007-psql-success.png`](../evidence/screenshots/INC-007-psql-success.png).
- **Evidence limitation:** The repository intentionally does not store the host, username, password, connection string, raw terminal secret input, or production availability data.

## Root cause

- **Root cause:** The initial external connection used an invalid database password.
- **Contributing factors:** Connection details contain several independent values, and a password failure can be misdiagnosed as a network or Supabase availability problem.
- **Why the initial symptom could be misleading:** Reaching the host does not prove the credentials are correct, while a failed authentication does not prove the database is down.

## Remediation

- **Fix applied in the lab:** Retried the same Session Pooler host, port, database, username, and TLS configuration with the correct database password.
- **Why this is the smallest safe fix:** Only the invalid credential was corrected; no network, database, or pooler configuration was changed.
- **Security or data risks considered:** Keep passwords out of shell history where possible, avoid screenshots containing secrets, and use a least-privilege database role for operational tools.
- **Rollback or recovery plan:** If the credential is suspected to be compromised, rotate it through the approved secret-management process and update dependent clients without publishing the new value.
- **Workload consideration:** Choose Direct, Session Pooler, or Transaction Pooler based on the client and transaction behavior rather than using a different endpoint as a blind workaround.

## Customer-facing response

> **Subject:** Update on the external PostgreSQL connection failure
>
> Hi [customer],
>
> **What we found:** The connection reached the PostgreSQL endpoint, but authentication was rejected because the supplied database password was not valid. This error is different from a DNS, network, TLS, or database-availability failure.
>
> **What we checked:** We confirmed the intended Session Pooler connection method, retained the host, port, database, username, and TLS settings, and retried with the correct password. Please do not send the password or a full credential-bearing connection string in email.
>
> **How we verified the fix:** The connection succeeded over TLS. We then checked the database identity and queried the application table to confirm that the session reached the expected project and had the expected access.
>
> **Next step:** Please store the working credential in the approved secret manager and avoid putting it in scripts, screenshots, or client-side code. I will provide another update if the connection fails again under the intended workload.
>
> Regards,
> [Support Engineer]

## Internal escalation and handoff

- **Escalation needed:** Not for the isolated lab reproduction; escalate if correct credentials fail, connectivity or TLS errors appear, or credential compromise is suspected.
- **Team or owner:** Database/platform owner for endpoint and pooler questions; security owner if credentials may have been exposed.
- **Technical summary:** `psql` 16.14 reached the Session Pooler over TLS but failed authentication with an invalid password. Retrying the same connection target with the correct password succeeded; identity and application-table checks passed.
- **Evidence attached:** Redacted terminal output, successful TLS connection screenshot, session identity result, and application-table count.
- **Customer impact and urgency:** External diagnostic connection blocked in the simulation; database availability and SLA effect were not measured.
- **Specific question or decision needed:** Is the selected pooler suitable for this client and workload, and where should the credential be managed?
- **Next owner and follow-up time:** Database/platform owner to confirm connection guidance; support to update the customer after the redacted configuration is validated.

## Recovery validation

- **Original failing test:** External `psql` connection returned password authentication failure.
- **Post-fix result:** The same Session Pooler connection succeeded over TLS with the correct password.
- **Session validation:** `current_database()` and `current_user` confirmed the target session identity.
- **Application validation:** `select count(*) from public.support_tickets;` returned 50,004 rows in the lab capture.
- **Scope validation:** Confirmed for one external client and one connection method; other poolers, clients, and workloads were not tested.
- **Monitoring or follow-up period:** Not applicable to the lab; production would monitor connection failures, pooler saturation, authentication errors, and secret rotation impact.

## Prevention and learning

- Record connection method, host, port, database, username, and TLS mode separately in redacted troubleshooting notes.
- Classify DNS/network/TLS failures separately from authentication failures.
- Validate session identity and an application query after connecting.
- Use secret management and least-privilege database roles for external tools.
- Document when Direct, Session Pooler, or Transaction Pooler is appropriate.
- **Transferable lesson:** A successful connection requires both transport and identity validation; prove the session reached the expected database before declaring recovery.
