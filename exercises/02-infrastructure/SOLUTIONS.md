# Module 2: Infrastructure -- Solutions

## Exercise 1: VPC Endpoint Validation

### How VPC endpoints ensure traffic stays private

The `modules/vpc-endpoints/main.tf` creates two interface endpoints:

1. **Bedrock Runtime** (`com.amazonaws.${region}.bedrock-runtime`) -- handles model inference requests
2. **STS** (`com.amazonaws.${region}.sts`) -- handles IAM credential exchange for Bedrock access

Both are configured with `private_dns_enabled = true`. This is the critical setting: it creates a Route 53 private hosted zone that overrides the public DNS for `bedrock-runtime.us-east-1.amazonaws.com`, resolving it to the ENI's private IP address inside the VPC.

### What happens if `private_dns_enabled` is false?

The AWS SDK resolves `bedrock-runtime.us-east-1.amazonaws.com` to a public IP. Traffic leaves the VPC, crosses the internet, and reaches Bedrock's public endpoint. The VPC endpoint exists but is unused because nothing routes to it. You'd need to manually configure the SDK to use the VPC endpoint DNS name (`vpce-xxx.bedrock-runtime.us-east-1.vpce.amazonaws.com`), which Claude Code doesn't support.

### Validation script

```bash
#!/bin/bash
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
ENDPOINT="bedrock-runtime.${REGION}.amazonaws.com"

echo "Resolving ${ENDPOINT}..."
RESOLVED_IP=$(dig +short "${ENDPOINT}" | head -1)

if [[ -z "${RESOLVED_IP}" ]]; then
  echo "FAIL: Could not resolve ${ENDPOINT}"
  exit 1
fi

# Check if the IP is in RFC 1918 private range
if [[ "${RESOLVED_IP}" =~ ^10\. ]] || \
   [[ "${RESOLVED_IP}" =~ ^172\.(1[6-9]|2[0-9]|3[01])\. ]] || \
   [[ "${RESOLVED_IP}" =~ ^192\.168\. ]]; then
  echo "PASS: ${ENDPOINT} resolves to private IP ${RESOLVED_IP}"
  echo "Traffic will stay within the VPC."
else
  echo "FAIL: ${ENDPOINT} resolves to public IP ${RESOLVED_IP}"
  echo "VPC endpoint may not be configured or private_dns_enabled is false."
  exit 1
fi
```

## Exercise 2: Inference Profiles

### Why inference profiles instead of bare model IDs

Inference profiles provide:

1. **Cost attribution** -- CloudTrail logs the profile ARN, so you can track which team/project used which model
2. **Access control** -- IAM policies can allow/deny access to specific profiles without granting access to the underlying model
3. **Version management** -- When Anthropic releases a model update, you update the profile's `copy_from` ARN in one place, not every developer's configuration
4. **Cross-region inference** -- Profiles can route requests to models in different regions for capacity or compliance reasons

**If a developer uses the model ID directly:** The request bypasses your inference profile. You lose cost attribution, can't enforce access control at the profile level, and the developer might use a model version you haven't approved.

### Opus profile addition

Added to `modules/bedrock/main.tf`:

```hcl
resource "aws_bedrock_inference_profile" "opus" {
  name        = "${var.project_name}-opus"
  description = "Inference profile for Claude Opus"

  model_source {
    copy_from = "arn:aws:bedrock:${var.region}::foundation-model/anthropic.claude-opus-4-6-20260219"
  }

  tags = var.tags
}
```

And `outputs.tf`:

```hcl
output "opus_profile_arn" {
  description = "ARN of the Opus inference profile"
  value       = aws_bedrock_inference_profile.opus.arn
}
```

### Validation

```bash
cd environments/dev && terraform validate
```

## Exercise 3: Gateway Configuration

### ALB-based LLM gateway design

```hcl
resource "aws_security_group" "gateway" {
  name_prefix = "${var.project_name}-gateway-"
  description = "Security group for LLM gateway ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTPS from VPC"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTPS to VPC endpoints"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-gateway-sg"
  })
}

resource "aws_lb" "gateway" {
  name               = "${var.project_name}-llm-gateway"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.gateway.id]
  subnets            = var.private_subnet_ids

  tags = var.tags
}

resource "aws_lb_target_group" "bedrock" {
  name        = "${var.project_name}-bedrock-tg"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/"
    protocol = "HTTPS"
    matcher  = "200-499"
  }

  tags = var.tags
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.gateway.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bedrock.arn
  }
}
```

### Key assumptions this design makes

- **Internal ALB** -- developers access it via VPN or corporate network, not the public internet
- **TLS 1.3** -- uses a restrictive SSL policy for compliance
- **Target type `ip`** -- targets the VPC endpoint ENI IP addresses directly
- **No authentication at ALB level** -- relies on IAM credentials in the request (SigV4 signing)

For a production deployment, you'd add: WAF rules for request inspection, access logging to S3, custom health checks against Bedrock, and potentially a Lambda authorizer for user-level authentication.
