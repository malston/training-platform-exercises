# Training: Platform Engineer Exercises

Exercise materials for the [Platform Engineer Learning Path](https://malston.github.io/claude-code-wiki/training/platform-engineer-path/). Each module has hands-on exercises for deploying and managing Claude Code at scale.

## Project Structure

```
training-platform-exercises/
├── modules/              # Terraform modules
│   ├── vpc/              # VPC with private subnets and endpoints
│   ├── bedrock-endpoint/ # Bedrock VPC endpoint configuration
│   └── llm-gateway/      # LLM gateway proxy setup
├── environments/         # Environment-specific configs
│   ├── dev/              # Development environment
│   └── staging/          # Staging environment
├── policies/             # Managed settings, CLAUDE.md, permissions
├── templates/            # Rollout planning templates
├── exercises/            # Exercise instructions per module
└── CLAUDE.md             # Project conventions for Claude Code
```

## Prerequisites

- Terraform 1.5+
- AWS CLI configured (or use localstack for exercises that don't require real AWS)
- Claude Code CLI

## Getting Started

```bash
cd environments/dev
terraform init
terraform validate
terraform plan
```

## Exercises by Module

| Module             | Directory                      | Focus                                            |
| ------------------ | ------------------------------ | ------------------------------------------------ |
| 1. Architecture    | `exercises/01-architecture/`   | Request flow, control points, config hierarchy   |
| 2. Infrastructure  | `exercises/02-infrastructure/` | VPC endpoints, inference profiles, gateway setup |
| 3. Configuration   | `exercises/03-configuration/`  | Managed settings, CLAUDE.md hierarchy            |
| 4. Permissions     | `exercises/04-permissions/`    | Permission rules, sandboxing, cascade testing    |
| 5. Cost Management | `exercises/05-cost/`           | Budget controls, dashboards, rate limiting       |
| 6. Rollout         | `exercises/06-rollout/`        | Cohort planning, rollback, success metrics       |

Each exercise directory has a `README.md` with instructions.

## Solutions

This branch (`solutions`) contains worked solutions for every exercise. Each exercise directory has a `SOLUTIONS.md` explaining the approach and key decisions.

**Attempt the exercises first.** Switch to the `main` branch to work through exercises without seeing answers:

```bash
git checkout main
```

When you're ready to check your work, switch back:

```bash
git checkout solutions
```
