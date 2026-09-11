resource "aws_security_group" "app" {
  name        = "${var.environment}-app"
  description = "Application instances"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "database" {
  name        = "${var.environment}-database"
  description = "PostgreSQL, reachable from the application tier only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from the application tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
}
