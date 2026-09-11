output "endpoint" {
  description = "Connection endpoint."
  value       = aws_db_instance.this.endpoint
}

output "security_group_id" {
  description = "Security group attached to the instance, for callers that need to grant access."
  value       = aws_security_group.this.id
}
