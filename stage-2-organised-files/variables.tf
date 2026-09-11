variable "region" {
  description = "AWS region for every resource in this configuration."
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name, used for tagging and resource naming."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}
