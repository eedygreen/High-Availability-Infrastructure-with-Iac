locals {
  bucket_name = "localstack-s3-bucket"
  object_name = "config-dev.json"
  config_filename = "${path_relative_from_include()}/config-dev.json"
  units_path = read_terragrunt_config(find_in_parent_folders("config.hcl"))
  
}


unit "dev" {
  source = "${local.units_path.locals.s3_source}"
  path = "dev"
  values = {
    environment = "development"
    bucket_name = "${local.bucket_name}-dev"
    force_destroy = true
    object_name = local.object_name
    config_filename = local.config_filename
  }
}
