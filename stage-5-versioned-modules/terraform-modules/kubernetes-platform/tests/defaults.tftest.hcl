# If a module is a product, its interface is a contract - and a contract that is
# never tested is a suggestion.
#
# `mock_provider` synthesises provider responses, so these run with no AWS
# credentials and no billable resources:
#
#   terraform test
#
# See ../../../../docs/module-lifecycle.md for where this fits in a release.

mock_provider "aws" {
  # aws_iam_policy_document is computed by the provider, so the mock has to
  # return real JSON - aws_iam_role validates what it is handed.
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  name       = "test"
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-0a1b2c3d", "subnet-4e5f6a7b"]
}

run "defaults_are_safe" {
  command = plan

  assert {
    condition     = aws_eks_cluster.this.vpc_config[0].endpoint_public_access == false
    error_message = "The API server must not be internet-facing unless a caller opts in."
  }

  assert {
    condition     = aws_eks_cluster.this.vpc_config[0].endpoint_private_access == true
    error_message = "Private endpoint access must be enabled."
  }

  assert {
    condition     = contains(aws_eks_cluster.this.enabled_cluster_log_types, "audit")
    error_message = "Audit logging must be on by default - it is the one log nobody thinks to enable after an incident."
  }
}

run "default_node_group_is_created" {
  command = plan

  assert {
    condition     = length(aws_eks_node_group.this) == 1
    error_message = "The default node_groups value must create exactly one node group."
  }

  assert {
    condition     = aws_eks_node_group.this["default"].scaling_config[0].min_size == 2
    error_message = "The default node group must keep two nodes as a floor."
  }
}

run "node_groups_are_addressable_by_name" {
  command = plan

  variables {
    node_groups = {
      system = {
        instance_types = ["m7g.large"]
        min_size       = 3
        max_size       = 6
        desired_size   = 3
      }
      gpu = {
        instance_types = ["g5.xlarge"]
        min_size       = 0
        max_size       = 4
        desired_size   = 0
        labels         = { pool = "gpu" }
      }
    }
  }

  assert {
    condition     = length(aws_eks_node_group.this) == 2
    error_message = "Adding a node group must not require a change to this module."
  }

  assert {
    condition     = aws_eks_node_group.this["gpu"].labels["pool"] == "gpu"
    error_message = "Per-group labels must reach the node group."
  }
}

run "rejects_a_single_subnet" {
  command = plan

  variables {
    subnet_ids = ["subnet-0a1b2c3d"]
  }

  expect_failures = [var.subnet_ids]
}
