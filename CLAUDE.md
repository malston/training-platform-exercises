# Claude Code Platform Exercises

Terraform infrastructure and policy configurations for platform engineer training.

## Commands

- `cd environments/dev && terraform init` -- initialize Terraform providers
- `cd environments/dev && terraform validate` -- validate configuration
- `cd environments/dev && terraform plan` -- preview changes
- `cd environments/dev && terraform apply` -- apply changes

## Project Conventions

### Terraform

- Modules under `modules/` with standard `main.tf`, `variables.tf`, `outputs.tf`
- Environment configs under `environments/` reference modules
- Use `terraform.tfvars.example` for sample variable values (never commit real credentials)
- Pin provider versions in `versions.tf`
- Tag all resources with `Project`, `Environment`, and `ManagedBy` tags

### Policies

- Managed settings files under `policies/`
- Use JSON for machine-readable configs
- Use Markdown for CLAUDE.md and documentation
