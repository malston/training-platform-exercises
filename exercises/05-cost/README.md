# Module 5: Cost Management

Practice estimating costs, building dashboards, and configuring budget controls.

## Setup

Review the files in `cost/` before starting.

## Exercise 1: Calculate Team Cost

Run the cost calculator with different parameters:

```bash
python3 cost/cost-calculator.py --developers 100 --model sonnet
python3 cost/cost-calculator.py --developers 100 --model opus
python3 cost/cost-calculator.py --developers 25 --model sonnet
```

1. Compare the output across models. Ask Claude:

   > "Based on the cost calculator output, what's the cost difference between running 100 developers on Sonnet vs Opus? At what team size does the choice of model start to matter significantly?"

2. Ask Claude to adjust the assumptions:

   > "Modify the cost calculator to add a 'power_user' tier: 5% of developers who use 12 sessions per day with 40 turns per session. What happens to the total cost?"

## Exercise 2: CloudWatch Dashboard

Review `cost/cloudwatch-dashboard.json` and customize it.

1. Ask Claude to explain the dashboard:

   > "Walk me through each widget in cloudwatch-dashboard.json. What metrics would I need to emit from the LLM gateway to populate this dashboard?"

2. Ask Claude to add an alarm:

   > "Add a CloudWatch alarm that triggers when any single user exceeds $50/day in estimated cost. Include the SNS topic configuration."

## Exercise 3: Rate Limiting

Review `cost/gateway-rate-limit.yaml` and test the limits.

1. Ask Claude to evaluate the configuration:

   > "Review the rate limit configuration. Are the per-user daily limits reasonable for the cost estimates from Exercise 1? What happens when a developer hits the limit mid-task?"

2. Ask Claude to design a graduated response:

   > "Instead of hard rejecting at the limit, design a graduated system: warn at 80%, throttle (slower responses) at 90%, and reject at 100%. Update the YAML configuration."
