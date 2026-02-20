resource "aws_bedrock_inference_profile" "sonnet" {
  name        = "${var.project_name}-sonnet"
  description = "Inference profile for Claude Sonnet"

  model_source {
    copy_from = "arn:aws:bedrock:${var.region}::foundation-model/anthropic.claude-sonnet-4-20250514"
  }

  tags = var.tags
}

resource "aws_bedrock_inference_profile" "haiku" {
  name        = "${var.project_name}-haiku"
  description = "Inference profile for Claude Haiku"

  model_source {
    copy_from = "arn:aws:bedrock:${var.region}::foundation-model/anthropic.claude-haiku-4-5-20251001"
  }

  tags = var.tags
}

resource "aws_bedrock_inference_profile" "opus" {
  name        = "${var.project_name}-opus"
  description = "Inference profile for Claude Opus"

  model_source {
    copy_from = "arn:aws:bedrock:${var.region}::foundation-model/anthropic.claude-opus-4-6-20260219"
  }

  tags = var.tags
}
