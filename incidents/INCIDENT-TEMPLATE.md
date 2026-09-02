# Incident template — Support Engineering

Use this template for simulated incidents. Keep technical facts separate from assumptions, and label lab-only decisions clearly.

## Incident metadata

- **Incident ID:** `INC-XXX`
- **Title:**
- **Status:** Investigating / Resolved / Monitoring
- **Severity:**
- **Priority:**
- **Affected area:** PostgreSQL / Data API / RLS / Auth / Storage / Other
- **Customer impact:**
- **Detection or report:**
- **Lab disclaimer:** This is a self-directed simulated incident, not a production customer case.

## Customer symptom

Describe what the customer sees, using their likely wording where useful. Do not start with the presumed root cause.

## Initial assessment

- **What is confirmed:**
- **What is not yet confirmed:**
- **Initial assumptions:**
- **Immediate safety concern:**
- **First customer update:**

## Triage and prioritization

- **Why this priority was selected:**
- **Who or what may be affected:**
- **What I would investigate first:**
- **What I would defer:**
- **Escalation trigger:**

## Investigation

Record one hypothesis at a time. For each step, explain what the result would tell the support engineer.

1. **Check:**
   - **Reason:**
   - **Result:**
2. **Check:**
   - **Reason:**
   - **Result:**
3. **Check:**
   - **Reason:**
   - **Result:**

## Evidence

- **Evidence collected:**
- **Commands or requests:**
- **Logs or query output:**
- **Screenshots or artifacts:**
- **Evidence limitations:**

## Root cause

- **Root cause:**
- **Contributing factors:**
- **Why the initial symptom could be misleading:**

## Remediation

- **Fix applied or recommended:**
- **Why this is the smallest safe fix:**
- **Security or data risks considered:**
- **Rollback or recovery plan:**
- **Lab-only limitation, if applicable:**

## Customer-facing response

Write the response as if replying to the customer by email. Explain the problem and solution in plain language, include ordered steps where appropriate, and explain documentation links rather than dropping a link without context.

> **Subject:**
>
> Hi [customer],
>
> **What we found:**
>
> **What you should do:**
>
> **How to verify the fix:**
>
> **What happens next / when I will update you:**
>
> Regards,
> [Support Engineer]

## Internal escalation and handoff

- **Escalation needed:** Yes / No
- **Team or owner:**
- **Technical summary:**
- **Evidence attached:**
- **Customer impact and urgency:**
- **Specific question or decision needed:**
- **Next owner and follow-up time:**

## Recovery validation

- **Original failing test:**
- **Post-fix result:**
- **Authorization or security validation:**
- **Scope validation:**
- **Monitoring or follow-up period:**

## Prevention and learning

- **Runbook or documentation update:**
- **Alert, test, or guardrail to add:**
- **What another support engineer should check first next time:**
- **Transferable lesson:**
