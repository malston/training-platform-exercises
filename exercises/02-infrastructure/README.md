# Module 2: Infrastructure

Practice setting up the AWS infrastructure that routes Claude Code traffic through your VPC.

## Setup

Review the Terraform modules in `modules/` before starting. You should understand the VPC, VPC endpoints, and Bedrock module structure.

## Exercise 1: VPC Endpoint Validation

The `modules/vpc-endpoints/` module creates interface endpoints for Bedrock and STS.

1. Ask Claude to review the VPC endpoint configuration:

   > "Review the vpc-endpoints module. Does it correctly ensure that Bedrock API calls stay within the VPC? What would happen if private_dns_enabled were set to false?"

2. Ask Claude to add a validation test:

   > "Write a terraform test or a shell script that verifies the Bedrock VPC endpoint resolves to a private IP address, not a public one."

## Exercise 2: Inference Profiles

The `modules/bedrock/` module creates inference profiles for Sonnet and Haiku.

1. Ask Claude to explain why inference profiles matter:

   > "Why do we use inference profiles instead of bare model IDs? What happens if a developer uses the model ID directly instead of the inference profile ARN?"

2. Ask Claude to add an Opus profile:

   > "Add an inference profile for Claude Opus to the bedrock module. Follow the same pattern as Sonnet and Haiku."

3. Verify the module still validates: `cd environments/dev && terraform validate`

## Exercise 3: Gateway Configuration

Ask Claude to design an LLM gateway configuration:

> "Design a Terraform module for an ALB-based LLM gateway that sits between developer machines and the Bedrock VPC endpoint. It should: accept HTTPS on port 443, forward to the Bedrock endpoint, and include a security group that only allows traffic from the VPC CIDR."

Compare Claude's output to your organization's proxy or gateway requirements. What did it get right? What assumptions did it make?
