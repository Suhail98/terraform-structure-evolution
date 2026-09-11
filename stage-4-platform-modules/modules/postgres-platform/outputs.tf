output "endpoint" {
  description = "Connection endpoint."
  value       = aws_db_instance.this.endpoint
}

output "security_group_id" {
  description = "Security group attached to the instance."
  value       = aws_security_group.this.id
}

output "master_user_secret_arn" {
  description = "Secrets Manager secret holding the managed master password."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
