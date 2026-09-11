variable "name" {
  description = "Cluster name, also used as the prefix for supporting resources."
  type        = string
}

variable "kubernetes_version" {
  description = "EKS control plane version."
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "VPC the cluster runs in."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the control plane ENIs and the node groups."
  type        = list(string)
}

variable "node_groups" {
  description = <<-EOT
    Node groups to create, keyed by name. Modelling these as a map rather than
    separate module calls is what lets a caller add a GPU pool without the root
    module learning anything new about EKS.
  EOT

  type = map(object({
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    labels         = optional(map(string), {})
  }))

  default = {
    default = {
      instance_types = ["m7g.large"]
      min_size       = 2
      max_size       = 6
      desired_size   = 2
    }
  }
}

variable "log_retention_days" {
  description = "Retention for the control plane log group."
  type        = number
  default     = 30
}
