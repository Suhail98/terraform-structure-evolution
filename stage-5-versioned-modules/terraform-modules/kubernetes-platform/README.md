# `kubernetes-platform`

An EKS cluster and everything it cannot exist without: cluster and node IAM
roles, the control plane security group, the control plane log group, and node
groups as a map so a consumer can add a pool without this module learning
anything new.

Since v5.3.0 it also manages the core EKS addons — `vpc-cni`, `coredns`,
`kube-proxy` and `eks-pod-identity-agent` — so they stop drifting in as
hand-applied manifests nobody owns.

| | |
| --- | --- |
| Current release | `kubernetes-platform/v5.3.0` |
| Supported | `kubernetes-platform/v5.2.0` |
| Source | `git::https://github.com/Suhail98/terraform-structure-evolution.git//stage-5-versioned-modules/terraform-modules/kubernetes-platform?ref=kubernetes-platform/v5.3.0` |

## Usage

```hcl
module "platform" {
  source = "git::https://github.com/Suhail98/terraform-structure-evolution.git//stage-5-versioned-modules/terraform-modules/kubernetes-platform?ref=kubernetes-platform/v5.3.0"

  name       = "dev"
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  node_groups = {
    default = {
      instance_types = ["m7g.large"]
      min_size       = 1
      max_size       = 4
      desired_size   = 2
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `string` | — | Cluster name and prefix for supporting resources |
| `vpc_id` | `string` | — | VPC the cluster runs in |
| `subnet_ids` | `list(string)` | — | Control plane ENIs and node groups. At least two AZs |
| `kubernetes_version` | `string` | `"1.31"` | Control plane version |
| `node_groups` | `map(object)` | one `m7g.large` pool | Node groups keyed by name |
| `log_retention_days` | `number` | `30` | Control plane log group retention |
| `endpoint_public_access` | `bool` | `false` | Expose the API server to the internet |
| `addon_versions` | `map(string)` | `{}` | Version pins for the managed addons |

## Outputs

`cluster_name`, `cluster_endpoint`, `cluster_security_group_id`, `oidc_issuer_url`

## Tests

```sh
terraform init -backend=false
terraform test
```

The suite runs against `mock_provider`, so it needs no AWS credentials and
creates nothing. It asserts the things a consumer is entitled to rely on: the
API server is private by default, audit logging is on, the default node group has
a floor of two, the core addons are managed and pinnable, and a single-subnet
input is rejected at plan rather than discovered at apply.
