# Stage 1 - everything in one file.
#
# This is deliberately not "bad Terraform". For a lab, a proof of concept, a
# temporary environment or a genuinely small stack, one file buys you something
# valuable: you open the repository and immediately know what gets created.
#
# The problem it grows into is legibility, not correctness.

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Partial backend configuration: the bucket and key are supplied by
  # `terraform init -backend-config=...` so the same file works per workspace.
  backend "s3" {}
}

provider "aws" {
  region = var.region
}

variable "region" {
  description = "AWS region for every resource in this configuration."
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "demo"
  }
}

resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 0)
  availability_zone = "${var.region}a"

  tags = {
    Name = "demo-app"
  }
}

resource "aws_security_group" "app" {
  name        = "demo-app"
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

resource "aws_instance" "app" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.app.id
  vpc_security_group_ids = [aws_security_group.app.id]

  tags = {
    Name = "demo-app"
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}
