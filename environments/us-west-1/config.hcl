locals {
    aws_region = "us-west-2"
    base_repo =  "/home/isah-idris/Documents/GitHub/localstack/Infrastruture-As-Code-modules"# "git::https://github.com/eedygreen/Infrastruture-As-Code-modules.git"

    versions = {
        cluster = "v0.1.1-beta.6"
        s3 = "v0.1.1-beta.6"
        ingress = "v0.1.1-beta.6"
        vpc = "v0.1.1-beta.6"
        app = "v0.1.1-beta.6"
        dev = "v0.1.0" # version for environment (dev, prod..) must correspon release version as others
        prod = "v0.1.0"
        prod = "v0.1.0"
    }

    cluster_source = "${local.base_repo}//units/cluster?ref=${local.versions.cluster}"
    ingress_source = "${local.base_repo}//units/ingress?ref=${local.versions.ingress}"
    s3_source = "${local.base_repo}//units/s3?ref=${local.versions.s3}"
    app_source = "${local.base_repo}//units/app?ref=${local.versions.app}"
    vpc_source = "${local.base_repo}//units/vpc?ref=${local.versions.vpc}"
}
