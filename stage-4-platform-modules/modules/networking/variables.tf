variable "name" {
  description = "Name prefix for every resource this module creates."
  type        = string
}

variable "cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones to spread subnets across."
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Route all private egress through one NAT gateway. Cheaper, and a single AZ failure domain - appropriate for dev, not for production."
  type        = bool
  default     = false
}
