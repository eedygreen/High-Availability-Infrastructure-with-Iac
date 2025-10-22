locals {
    aws_region = "us-east-1"
    base_repo = "git::https://github.com/eedygreen/Infrastruture-As-Code-modules.git"

    versions = {
        cluster = "v0.1.0-patch.2"
        s3 = "v0.1.1-beta.1"
        ingress = "v0.1.1-beta"
        app = "v0.1.0-patch.2"
        dev = "v0.1.0" # version for environment (dev, prod..) must correspon release version as others
        prod = "v0.1.0"
    }

    cluster_source = "${local.base_repo}//units/cluster?ref=${local.versions.cluster}"
    ingress_source = "${local.base_repo}//units/ingress?ref=${local.versions.ingress}"
    s3_source = "${local.base_repo}//units/s3?ref=${local.versions.s3}"
    app_source = "${local.base_repo}//units/app?ref=${local.versions.app}"
}