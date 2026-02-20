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

| Module             | Directory                       | Focus                                            |
| ------------------ | ------------------------------- | ------------------------------------------------ |
| 2. Infrastructure  | `exercises/01-infrastructure/`  | VPC endpoints, inference profiles, gateway setup |
| 3. Configuration   | `exercises/02-configuration/`   | Managed settings, CLAUDE.md hierarchy            |
| 4. Permissions     | `exercises/03-permissions/`     | Permission rules, sandboxing, cascade testing    |
| 5. Cost Management | `exercises/04-cost-management/` | Budget controls, dashboards, rate limiting       |
| 6. Rollout         | `exercises/05-rollout/`         | Cohort planning, rollback, success metrics       |

Module 1 (Architecture) is conceptual and has no hands-on exercises.
