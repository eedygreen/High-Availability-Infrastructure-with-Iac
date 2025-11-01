locals {

  units_path = read_terragrunt_config(find_in_parent_folders("config.hcl"))

}


unit "dev" {
  source = "${local.units_path.locals.vpc_source}"
  path = "dev"
  values = {
    env = "dev"
    region  = "${local.units_path.locals.aws_region}"
    cidr = "192.168.0.0/16"
    public_subnets = ["192.168.10.0/24", "192.168.11.0/24", "192.168.12.0/24"]
    private_subnets = ["192.168.20.0/24", "192.168.21.0/24", "192.168.22.0/24"]
    database_subnets = ["192.168.3.0/24", "192.168.4.0/24", "192.168.5.0/24" ]
    elasticache_subnets = ["192.168.6.0/24", "192.168.7.0/24", "192.168.8.0/24"]
    force_destroy = true
  }
}
