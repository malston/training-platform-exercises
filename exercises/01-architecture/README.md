# Module 1: Architecture

Map the end-to-end request flow and identify where control points exist.

## Exercise 1: Diagram the Request Flow

Draw the four-hop request path for your organization:

```
Developer workstation → ____________ → ____________ → ____________
```

For each hop, answer:

- Does traffic traverse the public internet?
- Who controls this hop (developer, platform team, cloud provider)?
- What fails if this hop goes down?

## Exercise 2: Identify Enforcement Points

Claude Code has two enforcement points: the LLM gateway (controls traffic in transit) and managed settings (controls behavior on the workstation).

For each policy below, decide which enforcement point handles it:

| Policy                                   | Gateway | Managed Settings | Both |
| ---------------------------------------- | ------- | ---------------- | ---- |
| Block Opus access for junior developers  |         |                  |      |
| Prevent `sudo` commands                  |         |                  |      |
| Rate-limit tokens per user per day       |         |                  |      |
| Route all traffic through VPC endpoints  |         |                  |      |
| Disable `--dangerously-skip-permissions` |         |                  |      |
| Log all requests for audit               |         |                  |      |

## Exercise 3: Configuration Hierarchy

The configuration hierarchy is:

```
managed settings > CLI flags > local settings > project settings > user settings
```

A developer sets `CLAUDE_CODE_USE_BEDROCK=0` in their user settings, but your managed settings set `CLAUDE_CODE_USE_BEDROCK=1`. What happens? Why?

Now consider: a project's `.claude/settings.json` adds `allow` rules for `Bash(npm *)`. Your managed settings deny `Bash(curl *)`. Can the project override the managed deny? Can the project add its own allows?

Write down the rule evaluation order and explain why deny rules from any scope always win.
