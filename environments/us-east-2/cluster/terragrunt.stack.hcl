locals {
  ingress_ready = true
  cluster_version = "1.33.0"
  cluster_context = "test-cluster"
  cluster_name = "t-cluster"
  units_path = read_terragrunt_config(find_in_parent_folders("config.hcl"))
}

unit "dev" {
  source = "${local.units_path.locals.cluster_source}"
  path = "dev"
  values = {
    environment = "dev"
    listen_address = "0.0.0.0"
    cluster_name = "${local.cluster_name}-dev"
    cluster_version = local.cluster_version
    cluster_context = local.cluster_context
    ingress_ready = local.ingress_ready
  }
}

unit "prod" {
  source = "${local.units_path.locals.cluster_source}"
  path = "prod"
  values = {
    environment = "prod"
    listen_address = "0.0.0.0"
    cluster_name = "${local.cluster_name}-prod"
    cluster_version = local.cluster_version
    cluster_context = local.cluster_context
    ingress_ready = local.ingress_ready

  }
}
