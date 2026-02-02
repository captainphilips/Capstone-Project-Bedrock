############################
# VPC Module Outputs
############################
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.bedrock.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "nat_gateway_ips" {
  description = "NAT Gateway public IPs"
  value       = [for eip in aws_eip.nat : eip.public_ip]
}
