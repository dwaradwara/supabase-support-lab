# Version 2 evidence still required

The original screenshots were removed from the Version 2 branch because they
included unrelated browser tabs, desktop applications and visible ChatGPT UI.
They remain recoverable from Git history.

Do not mark Version 2 incidents as validated until clean evidence is captured
from the hosted lab project.

## Capture rules

- Crop to the relevant command, log event or SQL result.
- Exclude browser history, ChatGPT URLs, personal tabs and notifications.
- Never include passwords, full JWTs, refresh tokens or secret/service-role keys.
- Record exact UTC timestamps and request IDs when useful for log correlation.
- Prefer raw text output for SQL plans and diagnostics.
- Capture both successful and denied/security validation.

## Required evidence

### INC-001 / INC-002

- anonymous result: zero rows
- User A own rows and zero cross-user rows
- User B own rows and zero cross-user rows
- unrelated authenticated user: zero rows

### INC-003

- complete before plan in text form
- complete after plan in text form
- repeated execution notes

### INC-004

- blocked and blocking PID output
- `wait_event_type`, `wait_event` and transaction age
- recovery after rollback

### INC-005

- sanitized request/response
- matching Unified Logs event

### INC-006

- original transport status plus JSON payload
- permitted own-folder upload
- denied cross-user upload

### INC-007

- current basic credential evidence will be replaced by a connection-pressure
  and pooling incident in the advanced phase.
