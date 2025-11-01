locals {
  
  localstack_endpoint = "http://127.0.0.1:4566"
  aws_skip_flags = {
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
  }
  kubernetes_config = {
    config_path = "~/.kube/config"
    config_context = "test-cluster"
  }
  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("config.hcl"))

  # extract the variables
  aws_region = local.region_vars.locals.aws_region

}

remote_state {

    backend = "s3"
    generate = {
      path = "backend.tf"
      if_exists = "overwrite_terragrunt"
    }

    config = {
      bucket = "terragrunt-state-bucket"
      key = "${path_relative_to_include()}/terraform.tfstate"
      region = local.aws_region
      encrypt = true
      use_lockfile = true
      skip_credentials_validation = "${local.aws_skip_flags.skip_credentials_validation}"
      skip_metadata_api_check = "${local.aws_skip_flags.skip_metadata_api_check}"
      skip_region_validation = "${local.aws_skip_flags.skip_region_validation}"
      endpoints = {
        sts = "${local.localstack_endpoint}"
        s3 = "${local.localstack_endpoint}"
      }
    }

}

generate "providers" {
    path = "providers.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<EOF
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
provider "kubernetes" {
  # Docs: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
  config_path    = local.kubernetes_config.config_path
  config_context = local.kubernetes_config.cluster_context
}
provider "helm" {
  # Docs: https://registry.terraform.io/providers/hashicorp/helm/latest/docs
  kubernetes = {
    config_path    = local.kubernetes_config.config_path
    config_context = local.kubernetes_config.cluster_context
  }
}
# Localstack instead of AWS
provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "${local.aws_region}"

  s3_use_path_style           = true
  skip_credentials_validation = "${local.aws_skip_flags.skip_credentials_validation}"
  skip_metadata_api_check = "${local.aws_skip_flags.skip_metadata_api_check}"
  skip_requesting_account_id  = true

  endpoints {
    sts = "${local.localstack_endpoint}"
    s3 = "${local.localstack_endpoint}" # Localstack S3 service
    ec2 = "${local.localstack_endpoint}"
    iam = "${local.localstack_endpoint}"
  }

}
EOF
}

# All resources to inherit region variables
inputs = merge(
  local.region_vars.locals,
)
