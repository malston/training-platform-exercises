output "bedrock_endpoint_id" {
  description = "ID of the Bedrock VPC endpoint"
  value       = aws_vpc_endpoint.bedrock.id
}

output "bedrock_endpoint_dns" {
  description = "DNS entries for the Bedrock VPC endpoint"
  value       = aws_vpc_endpoint.bedrock.dns_entry
}

output "sts_endpoint_id" {
  description = "ID of the STS VPC endpoint"
  value       = aws_vpc_endpoint.sts.id
}

output "security_group_id" {
  description = "Security group ID for VPC endpoints"
  value       = aws_security_group.vpc_endpoints.id
}
