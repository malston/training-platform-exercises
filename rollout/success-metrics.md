# Success Metrics Dashboard

## Adoption Metrics

| Metric                    | Cohort 1 Target | Cohort 2 Target | Cohort 3 Target |
| ------------------------- | --------------- | --------------- | --------------- |
| Active users (weekly)     | > 80% of cohort | > 60% of cohort | > 40% of org    |
| Sessions per user per day | > 2             | > 2             | > 1.5           |
| Retention after 2 weeks   | > 90%           | > 80%           | > 70%           |

## Productivity Metrics

| Metric                     | Baseline      | Target        | How to Measure                                |
| -------------------------- | ------------- | ------------- | --------------------------------------------- |
| PR cycle time              | [current avg] | 20% reduction | GitHub API: time from first commit to merge   |
| PRs per developer per week | [current avg] | 15% increase  | GitHub API: merged PR count                   |
| Bug reopen rate            | [current avg] | 10% reduction | Issue tracker: reopened bugs / total bugs     |
| Code review turnaround     | [current avg] | 15% reduction | GitHub API: time from PR open to first review |

## Quality Metrics

| Metric                | Baseline       | Threshold   | Action if Exceeded                |
| --------------------- | -------------- | ----------- | --------------------------------- |
| Test coverage         | [current %]    | No decrease | Investigate and remediate         |
| Production incidents  | [current rate] | No increase | Review Claude Code usage patterns |
| Security findings     | [current rate] | No increase | Tighten managed settings          |
| Lint/style violations | [current rate] | No increase | Update CLAUDE.md conventions      |

## Cost Metrics

| Metric              | Budget   | Alert At      | Action                       |
| ------------------- | -------- | ------------- | ---------------------------- |
| Per-user daily cost | $50      | $40 (80%)     | Notify user                  |
| Per-team daily cost | $500     | $400 (80%)    | Notify team lead             |
| Monthly total       | [budget] | 80% of budget | Review with finance          |
| Cache hit rate      | > 75%    | < 60%         | Investigate session patterns |

## Satisfaction Metrics

| Metric                       | Target      | Collection Method       |
| ---------------------------- | ----------- | ----------------------- |
| Developer satisfaction score | > 4.0/5.0   | Monthly survey          |
| Would recommend to colleague | > 80% yes   | Monthly survey          |
| Top complaints               | Categorized | Survey + Slack feedback |
| Feature requests             | Prioritized | Survey + Slack feedback |

## Reporting Cadence

- **Daily**: Cost dashboard review (automated)
- **Weekly**: Adoption and usage metrics (automated report)
- **Bi-weekly**: Quality metrics review (team meeting)
- **Monthly**: Full metrics report to leadership (slide deck)
