# Module 5: Cost Management -- Solutions

## Exercise 1: Calculate Team Cost

### Running the calculator

```bash
python3 cost/cost-calculator.py --developers 100 --model sonnet
python3 cost/cost-calculator.py --developers 100 --model opus
python3 cost/cost-calculator.py --developers 25 --model sonnet
```

### Results comparison

| Scenario         | Per dev/month | Total monthly |
| ---------------- | ------------- | ------------- |
| 100 devs, Sonnet | ~$107         | ~$10,700      |
| 100 devs, Opus   | ~$186         | ~$18,600      |
| 25 devs, Sonnet  | ~$107         | ~$2,675       |

**Key observations:**

- Opus is ~1.7x more expensive than Sonnet per developer (mostly driven by the 1.67x higher output token price: $25 vs $15)
- Per-developer cost is constant regardless of team size -- scaling is linear
- The heavy users (20% of team) account for ~45% of total cost
- Cache hit rates significantly affect cost. At 85% cache hits for heavy users, most input tokens are billed at the cache read rate ($0.30/MTok for Sonnet vs $3.00/MTok for uncached)

**At what team size does model choice matter?** At 10 developers, the difference is ~$790/month (probably negligible). At 100 developers, it's ~$7,900/month. At 500 developers, it's ~$39,500/month -- significant enough to justify model tiering (Sonnet as default, Opus for specific tasks).

### Adding a power_user tier

Add to the `DEFAULT_PATTERNS` dict:

```python
"power_user": {
    "percentage": 0.05,
    "sessions_per_day": 12,
    "turns_per_session": 40,
    "input_tokens_per_turn": 5000,
    "output_tokens_per_turn": 3000,
    "cache_hit_rate": 0.90,
},
```

Adjust other tier percentages accordingly (e.g., heavy 18%, moderate 47%, light 30%, power_user 5%).

Power users at 12 sessions x 40 turns = 480 turns/day generate significantly more tokens. Their cache hit rate is higher (0.90) because long sessions keep the cache warm.

## Exercise 2: CloudWatch Dashboard

### Widget explanations

| Widget                          | Metric                             | What It Shows                                | Required Data Source                                |
| ------------------------------- | ---------------------------------- | -------------------------------------------- | --------------------------------------------------- |
| Daily Token Consumption by Team | `ClaudeCode/InputTokens` by Team   | How many input tokens each team uses per day | Gateway emits `PutMetricData` with `Team` dimension |
| Daily Cost Estimate             | `ClaudeCode/EstimatedCost` by Team | Dollar cost estimate per team per day        | Gateway calculates `tokens * price` and emits       |
| Request Volume                  | `ClaudeCode/RequestCount`          | Total API calls per hour                     | Gateway increments counter per request              |
| Cache Hit Rate                  | `ClaudeCode/CacheHitRate`          | Percentage of input tokens served from cache | Bedrock response includes cache statistics          |
| Rate Limit Events               | `ClaudeCode/RateLimitHits`         | How often users hit rate limits              | Gateway emits on 429 responses                      |
| Monthly Cost Summary            | `ClaudeCode/EstimatedCost`         | Cumulative monthly spend                     | Same as daily cost, 30-day period                   |

### Gateway metric emission

The gateway needs to call `PutMetricData` after each request:

```python
cloudwatch.put_metric_data(
    Namespace='ClaudeCode',
    MetricData=[
        {
            'MetricName': 'InputTokens',
            'Value': response['usage']['input_tokens'],
            'Unit': 'Count',
            'Dimensions': [
                {'Name': 'Team', 'Value': team_name},
                {'Name': 'User', 'Value': user_id},
            ]
        },
        {
            'MetricName': 'EstimatedCost',
            'Value': calculate_cost(response['usage']),
            'Unit': 'None',
            'Dimensions': [
                {'Name': 'Team', 'Value': team_name},
            ]
        },
    ]
)
```

### CloudWatch alarm for $50/day per user

```json
{
  "AlarmName": "ClaudeCode-HighSpendUser",
  "AlarmDescription": "Alert when any user exceeds $50/day in Claude Code usage",
  "Namespace": "ClaudeCode",
  "MetricName": "EstimatedCost",
  "Dimensions": [{ "Name": "User", "Value": "*" }],
  "Statistic": "Sum",
  "Period": 86400,
  "EvaluationPeriods": 1,
  "Threshold": 50.0,
  "ComparisonOperator": "GreaterThanThreshold",
  "AlarmActions": ["arn:aws:sns:us-east-1:123456789012:claude-code-alerts"],
  "TreatMissingData": "notBreaching"
}
```

Note: Per-user alarms require one alarm per user or a composite metric. A more practical approach is to have the gateway check per-user spend and emit a custom metric (`HighSpendUser`) when the threshold is crossed, with a single alarm on that metric.

## Exercise 3: Rate Limiting

### Are the per-user daily limits reasonable?

The calculator shows a heavy Sonnet user at ~200 turns/day. At ~3,000 input tokens + ~1,500 output tokens per turn, that's ~900K tokens/day. The rate limit is 500K tokens/day -- this would throttle heavy users mid-afternoon.

**Recommendation:** Increase per-user daily limit to 1,000,000 tokens for Sonnet, or implement graduated response (below) to avoid hard cutoffs during productive work.

### Graduated response configuration

```yaml
rate_limits:
  per_user_daily:
    key: "user_id"
    tiers:
      - threshold: 0.80 # 80% of budget
        action: "warn"
        message: "You've used 80% of your daily token budget."
        response_header: "X-Budget-Warning: 80-percent"
      - threshold: 0.90 # 90% of budget
        action: "throttle"
        delay_ms: 2000
        message: "Approaching daily limit. Responses may be slower."
        response_header: "X-Budget-Warning: throttled"
      - threshold: 1.00 # 100% of budget
        action: "reject"
        status_code: 429
        message: "Daily token budget exceeded. Resets at midnight UTC."
    budgets:
      sonnet: 1000000
      opus: 500000
      haiku: 2000000

  per_user_burst:
    limit: 30
    window: 60
    key: "user_id"
    action: "throttle"

  per_team_daily:
    limit: 10000000
    window: 86400
    key: "team_id"
    tiers:
      - threshold: 0.80
        action: "notify_team_lead"
      - threshold: 1.00
        action: "reject"
```

The graduated approach prevents developers from losing work mid-task. At 80%, they get a warning header that IDE integrations can display. At 90%, responses slow down (natural signal to wrap up). At 100%, requests are rejected with a clear message.
