output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "API server endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "Security group attached to the control plane."
  value       = aws_security_group.cluster.id
}

output "oidc_issuer_url" {
  description = "OIDC issuer, for binding Kubernetes service accounts to IAM roles."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
