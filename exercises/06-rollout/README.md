# Module 6: Phased Rollout

Practice planning a phased rollout with cohort selection, rollback procedures, and success metrics.

## Setup

Review the templates in `rollout/` before starting.

## Exercise 1: Draft Your Cohort 1 Roster

Open `rollout/cohort-roster.md` and fill it out.

1. Ask Claude to help select champions:

   > "Based on the selection criteria in cohort-roster.md, help me draft a Cohort 1 roster. My org has teams: backend (15 devs), frontend (12 devs), platform (8 devs), data (6 devs), and mobile (10 devs). Suggest 25 people with a rationale for each."

2. Ask Claude to identify risks:

   > "What are the risks of this cohort composition? Are any teams over- or under-represented? What happens if our strongest champion leaves mid-pilot?"

## Exercise 2: Write a Rollback Plan

Open `rollout/rollback-playbook.md` and customize it.

1. Ask Claude to adapt it:

   > "Adapt the rollback playbook for our organization. We use Jamf for MDM, Okta for identity, and have a 4-hour SLA for security incidents. What changes are needed?"

2. Ask Claude to simulate a scenario:

   > "Walk me through the rollback process if a developer accidentally commits an API key to a public repo using Claude Code. Which rollback level applies, and what are the exact steps?"

## Exercise 3: Define Success Metrics

Open `rollout/success-metrics.md` and fill in baselines.

1. Ask Claude to make the metrics concrete:

   > "Our current PR cycle time averages 3 days, we merge about 8 PRs per developer per week, and our test coverage is 72%. Fill in the success metrics with realistic targets for a 100-person engineering org."

2. Ask Claude to design the reporting:

   > "Write a script or query that calculates the 'active users' metric using CloudWatch logs from the LLM gateway. An active user is someone who made at least one API call in the past 7 days."
