# Module 6: Phased Rollout -- Solutions

## Exercise 1: Draft Your Cohort 1 Roster

### Example roster for a 51-person org

| Name         | Team     | Role                 | Seniority | Rationale                                                 |
| ------------ | -------- | -------------------- | --------- | --------------------------------------------------------- |
| Alice Chen   | Backend  | Staff Engineer       | Senior    | CLI power user, high influence, writes complex services   |
| Bob Kim      | Backend  | Senior Engineer      | Senior    | Testing champion, good feedback loop habits               |
| Carlos Diaz  | Backend  | Engineer             | Mid       | Eager early adopter, represents mid-level perspective     |
| Diana Park   | Frontend | Tech Lead            | Senior    | Cross-stack visibility, can evaluate full-stack workflows |
| Eli Nguyen   | Frontend | Senior Engineer      | Senior    | Performance-focused, will stress-test context limits      |
| Fiona Walsh  | Frontend | Engineer             | Mid       | Fast learner, strong communicator for peer support        |
| Grace Liu    | Platform | Staff Engineer       | Senior    | Will assess infrastructure integration firsthand          |
| Hiro Tanaka  | Platform | Senior Engineer      | Senior    | Terraform/IaC expertise, validates infra exercises        |
| Ivan Petrov  | Platform | Engineer             | Mid       | Recent hire, fresh perspective on onboarding              |
| Julia Santos | Data     | Senior Data Engineer | Senior    | Python-heavy workflow, different usage patterns           |
| Kevin Okafor | Data     | Data Scientist       | Mid       | Jupyter/notebook workflows, edge case for CLI tool        |
| Lena Ivanova | Mobile   | Tech Lead            | Senior    | Cross-platform development, tests mobile build workflows  |
| Misha Huang  | Mobile   | Senior Engineer      | Senior    | CI/CD automation focus, will test integration patterns    |

_Continue to 25 with similar diversity..._

### Selection rationale

- **Team coverage:** Backend (3), Frontend (3), Platform (3), Data (2), Mobile (2) = 13 shown, extend to 25 with similar ratios
- **Seniority mix:** ~60% senior, ~40% mid-level. No juniors in Cohort 1 (they need more guidance, better for Cohort 2 after documentation is polished)
- **Champion characteristics:** Each person is either technically influential (staff/tech lead) or a strong communicator (will provide useful feedback)

### Composition risks

1. **Platform team over-represented for their size** (3 of 8 = 37% vs backend 3 of 15 = 20%). Platform engineers will use the tool differently (infrastructure tasks vs application code). Acceptable because they're also responsible for supporting the rollout.

2. **No junior developers.** Cohort 1 feedback will skew toward power-user patterns. When Cohort 2 adds juniors, the documentation and workflows may not address their needs. Mitigation: include at least 2-3 junior developers in Cohort 1.

3. **Single champion risk.** If Grace Liu (platform staff engineer) leaves mid-pilot, the team loses their primary infrastructure champion. Mitigation: always have 2+ people per team so knowledge isn't concentrated.

## Exercise 2: Write a Rollback Plan

### Adapted for Jamf + Okta + 4-hour SLA

**Level 1: Restrict (target: 15 minutes)**

1. Push restrictive managed settings via Jamf policy:

   ```bash
   # Jamf script payload
   jamf policy -event claude-code-restrict
   ```

   The policy pushes `managed-settings-strict.json` with `disableBypassPermissionsMode: true` and `allowManagedPermissionRulesOnly: true`.

2. Notify via Slack: `#engineering-alerts` channel
3. Document in incident tracker

**Level 2: Throttle (target: 30 minutes)**

1. Update gateway rate limits via config push:
   - Reduce per-user daily budget to 50,000 tokens
   - Add 5-second delay per request
2. Push updated Jamf policy with model restriction (Haiku only)
3. Notify via email + Slack

**Level 3: Suspend (target: 2 hours)**

1. Disable Bedrock access via Okta group removal:
   ```text
   Okta Admin → Groups → Claude-Code-Users → Remove cohort members
   ```
   This revokes the IAM role assumption that grants Bedrock access.
2. Push Jamf policy that clears `ANTHROPIC_API_KEY` env var
3. Notify affected users + their managers via email

**Level 4: Full Rollback (target: 4 hours -- within SLA)**

1. Disable all Bedrock inference profiles (Terraform `terraform destroy -target=module.bedrock`)
2. Remove managed settings from all machines: `jamf policy -event claude-code-remove`
3. Disable Okta app assignment for Claude Code
4. Notify: all engineering, leadership, security team
5. Preserve CloudWatch logs (set retention to 1 year)
6. Schedule post-incident review within 48 hours

### Scenario: Developer commits API key via Claude Code

**Applicable level:** Level 1 (Restrict) initially, escalate if needed.

**Step-by-step:**

1. **Detect:** CloudWatch alarm fires on credential pattern in commit (or security team notifies)
2. **Contain (5 min):** Revoke the exposed credential immediately (rotate API key)
3. **Restrict (15 min):** Push strict managed settings via Jamf that deny `Bash(git push *)` temporarily
4. **Investigate (1 hour):** Review audit logs to confirm scope (which user, which repo, what credential)
5. **Remediate:** Force-push to remove the key from git history (`git filter-branch` or BFG), add `.env` deny rules to managed settings
6. **Document:** Write incident report, update managed settings with `Read(//**/.env)` deny rule
7. **Resume:** Push updated (not strict) managed settings that include the new `.env` protection

**Escalation criteria:** If the credential was for a production system and may have been used by an attacker, escalate to Level 3 (suspend) while the security team investigates.

## Exercise 3: Define Success Metrics

### Filled metrics with baselines

**Productivity:**

| Metric                 | Baseline | Cohort 1 Target           | Cohort 2 Target           |
| ---------------------- | -------- | ------------------------- | ------------------------- |
| PR cycle time          | 3 days   | 2.4 days (20% reduction)  | 2.1 days (30% reduction)  |
| PRs per dev per week   | 8        | 9.2 (15% increase)        | 10 (25% increase)         |
| Bug reopen rate        | 12%      | 10.8% (10% reduction)     | 9.6% (20% reduction)      |
| Code review turnaround | 6 hours  | 5.1 hours (15% reduction) | 4.2 hours (30% reduction) |

**Cost:**

| Metric                   | Budget  | Alert At     | Action                       |
| ------------------------ | ------- | ------------ | ---------------------------- |
| Per-user daily cost      | $50     | $40 (80%)    | Notify user via Slack        |
| Per-team daily cost      | $500    | $400 (80%)   | Notify team lead             |
| Monthly total (100 devs) | $12,000 | $9,600 (80%) | Review with finance          |
| Cache hit rate           | > 75%   | < 60%        | Investigate session patterns |

### Active users CloudWatch Insights query

```text
fields @timestamp, @message
| filter @message like /user_id/
| stats count_distinct(user_id) as active_users by bin(7d) as week
| sort week desc
| limit 12
```

For a more precise query using the gateway's structured logs:

```text
fields user_id, @timestamp
| filter @timestamp > ago(7d)
| stats count(*) as request_count by user_id
| filter request_count > 0
| stats count(*) as active_users
```

This returns the count of unique users who made at least one API call in the past 7 days.
