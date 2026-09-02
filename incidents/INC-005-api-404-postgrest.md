# INC-005 - Data API 404 / PostgREST resource error

## Simulated customer ticket

> A Data API request that should return support tickets now returns HTTP 404.

## Original evidence

The foundational reproduction used a misspelled resource path:

```text
/rest/v1/support_ticketssss?select=*
```

The response contained HTTP 404, PostgREST code `PGRST205` and a hint pointing
to `public.support_tickets`. The matching GET was visible in Unified Logs.

## Root cause

The request referred to a resource PostgREST could not find in its schema cache.
In this foundational reproduction, the immediate cause was the misspelled table
name rather than platform availability.

## Fix and validation

The path was corrected to:

```text
/rest/v1/support_tickets?select=*
```

The request returned HTTP 200. An anonymous request could still contain `[]`
because RLS visibility is separate from resource resolution.

## Support reasoning

A 404 from the Data API is not sufficient evidence that Supabase is down. Read
the PostgREST code, message and hint; verify the project, exposed schema and
resource name; then correlate the exact timestamp/request in Unified Logs.

## Version 2 evidence

The original screenshots were removed because they contained unrelated browser
and desktop context. A clean sanitized request/response and matching log event
must be recaptured before this incident is marked validated in Version 2.

## Planned advanced extension

The typo scenario remains as a foundational case. A later advanced incident will
cover a resource that exists but is unavailable because of schema exposure,
migration or schema-cache behavior.
