# Rollback Playbook

## Trigger Conditions

Initiate rollback if any of the following occur:

- [ ] Security incident involving Claude Code
- [ ] Cost exceeds 150% of projected budget for 3 consecutive days
- [ ] Production incident attributed to Claude Code usage
- [ ] Data exfiltration or credential exposure

## Rollback Levels

### Level 1: Restrict (minutes)

Reduce permissions without removing access.

1. Push restrictive managed settings via MDM:
   - Set `disableBypassPermissionsMode: true`
   - Add deny rules for the problematic behavior
   - Set `allowManagedPermissionRulesOnly: true`
2. Notify affected teams via Slack
3. Document the restriction and reason

### Level 2: Throttle (minutes)

Reduce usage without removing access.

1. Update gateway rate limits:
   - Reduce per-user daily token budget to 50,000
   - Reduce per-team budget proportionally
2. Push updated managed settings with restricted model access
3. Notify all users via email

### Level 3: Suspend (hours)

Remove access for a specific cohort.

1. Revoke API keys or Bedrock access for the cohort's IAM roles
2. Push managed settings with `ANTHROPIC_API_KEY: ""` to clear credentials
3. Notify affected users and their managers
4. Preserve all logs for investigation

### Level 4: Full Rollback (hours)

Remove access for all users.

1. Revoke all API keys / Bedrock cross-region inference profiles
2. Remove managed settings from all machines via MDM
3. Notify all users, engineering leadership, and security team
4. Preserve all logs and audit trails
5. Schedule post-incident review

## Communication Template

```
Subject: Claude Code Access [Restricted/Suspended/Revoked]

Team,

We are [restricting/suspending/revoking] Claude Code access effective
immediately due to [brief reason].

Impact: [who is affected and how]
Duration: [expected timeline]
Next steps: [what users should do]

We will provide an update by [date/time].

Questions: Contact [platform team channel/email]
```

## Post-Rollback Checklist

- [ ] Root cause identified
- [ ] Remediation plan documented
- [ ] Security team sign-off (if security incident)
- [ ] Updated managed settings prepared for re-enablement
- [ ] Communication plan for re-enablement
- [ ] Lessons learned documented
