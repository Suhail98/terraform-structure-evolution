resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "main" {
  identifier     = "${var.environment}-postgres"
  engine         = "postgres"
  engine_version = "16.4"
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_encrypted = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]

  username = "platform"
  # The password is generated and rotated by AWS in Secrets Manager, so it never
  # exists in Terraform and cannot leak from state. See ../docs/secrets.md for
  # what `sensitive = true` does and does not do.
  manage_master_user_password = true

  skip_final_snapshot = true
}
