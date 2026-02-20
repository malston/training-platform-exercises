output "sonnet_profile_arn" {
  description = "ARN of the Sonnet inference profile"
  value       = aws_bedrock_inference_profile.sonnet.arn
}

output "haiku_profile_arn" {
  description = "ARN of the Haiku inference profile"
  value       = aws_bedrock_inference_profile.haiku.arn
}
