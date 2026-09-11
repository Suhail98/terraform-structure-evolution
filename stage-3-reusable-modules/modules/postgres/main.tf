resource "aws_db_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "this" {
  name        = "${var.name}-postgres"
  description = "PostgreSQL"
  vpc_id      = var.vpc_id
}

resource "aws_db_instance" "this" {
  identifier     = var.name
  engine         = "postgres"
  engine_version = "16.4"
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_encrypted = true
  multi_az          = var.multi_az

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  username = "platform"

  skip_final_snapshot = !var.multi_az
}
