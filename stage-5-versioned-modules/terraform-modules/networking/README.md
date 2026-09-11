# `networking`

VPC, subnet tiers (public / private / database), NAT egress and route tables.

| | |
| --- | --- |
| Current release | `networking/v3.2.0` |
| Source | `git::https://github.com/Suhail98/terraform-structure-evolution.git//stage-5-versioned-modules/terraform-modules/networking?ref=networking/v3.2.0` |

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `string` | — | Name prefix for every resource |
| `cidr` | `string` | — | CIDR block for the VPC |
| `availability_zones` | `list(string)` | — | AZs to spread subnets across |
| `single_nat_gateway` | `bool` | `false` | One NAT gateway instead of one per AZ. Cheaper, single failure domain — dev only |

## Outputs

`vpc_id`, `vpc_cidr`, `public_subnet_ids`, `private_subnet_ids`, `database_subnet_ids`
