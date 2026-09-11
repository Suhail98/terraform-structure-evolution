output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = aws_subnet.private[*].id
}

output "database_endpoint" {
  description = "Connection endpoint for the PostgreSQL instance."
  value       = aws_db_instance.main.endpoint
}
