# High Availability Infrastructure with IaC

This repository contains the Infrastructure as Code (IaC) implementation for a multi-region, highly available (HA) infrastructure estate using Terraform and Terragrunt. The infrastructure can be deployed and tested locally using LocalStack before applying to production AWS environments. Also, this is your gateway to Platform Engineering, creating reusable components. 


> This is for Educational Purposes for you to practice provisioning HA environments.
> If you want to follow the production usage, see [production](https://gitkraken.dev/link/dnNjb2RlOi8vZWFtb2Rpby5naXRsZW5zL2xpbmsvci8vZi9SRUFETUUubWQ%2FdXJsPWh0dHBzJTNBJTJGJTJGZ2l0aHViLmNvbSUyRmVlZHlncmVlbiUyRkhpZ2gtQXZhaWxhYmlsaXR5LUluZnJhc3RydWN0dXJlLXdpdGgtSWFjLmdpdCZsaW5lcz01NA%3D%3D?origin=gitlens) configuration.

## Requirements

### Terraform (>= 1.9.0)
- Install Terraform using your preferred package manager or download from [Terraform Downloads](https://www.terraform.io/downloads.html)
- Verify installation:
  `terraform version`

### Terragrunt (>= 0.45.0)
- Install Terragrunt using your preferred package manager or download from [Terragrunt Releases](https://github.com/gruntwork-io/terragrunt/releases)
- Verify installation:
  `terragrunt --version`

### LocalStack for Cloud Development
LocalStack provides a local AWS cloud stack for development and testing.

1. Install LocalStack:
   `pip install localstack`

2. Start LocalStack:
   `localstack start`

#### AWS Cloud: Local Backend Configuration
Configure the local S3 backend in LocalStack:

1. Create a backend bucket:
   `aws --endpoint-url=http://localhost:4566 s3 mb s3://terragrunt-state-bucket`

2. Enable versioning (recommended):
   ```bash
   aws --endpoint-url=http://localhost:4566 s3api put-bucket-versioning \
     --bucket terragrunt-state-bucket \
     --versioning-configuration Status=Enabled
   ```

#### Production Backend Options
For production environments, choose either:

1. **Existing S3 Bucket**
   - Create a dedicated S3 bucket with versioning enabled
   - Configure bucket encryption
   - Set up appropriate IAM permissions 

2. **Terraform Cloud**
   - Configure Terraform Cloud workspace
   - Set up VCS integration
   - Configure variables and permissions

#### Optional Requirements for Testing
1. **Go**
2. **Terratest**

## Usage

### Project Structure
```sh
.
├── environments/
│   ├── root.hcl              # Root configuration for all environments                 
│   ├── us-east-1/             # Region-specific configurations
│   │   ├── terragrunt.stack.hcl
│   │   ├── config.hcl          # shared configuration for all environments
│   │   └── cluster/{dev,prod,..}
│   ├── us-east-2/
│   │   ├── terragrunt.hcl
│   │   ├── config.hcl
│   │   └── s3/{dev,prod,..}
│   └── eu-west-1/
│       ├── terragrunt.hcl
│       ├── config.hcl
│       └── ingress/{dev,prod,..}

```
#### Required
To use this [module](https://github.com/eedygreen/Infrastruture-As-Code-modules), configure the followings
- Terragrunt root file `root.hcl`.
- Create a directory for the region(s) just as in this repo. You can name it anything. I will advice you do as in this repo for simplicity.
- Create a `config.hcl` file in each region for region specific configuration.
- Create a `terragrunt.stack.hcl` file in each region. See the project structure for better understanding.

### root file
```sh
remote_state {
    backend = "s3"
    generate = {
      path = "backend.tf"
      if_exists = "overwrite_terragrunt"
    }
    config = {
      bucket = "terragrunt-state-bucket" #You should configure your existing S3 bucket name
      key = "${path_relative_to_include()}/terraform.tfstate"
      region = local.aws_region
      endpoints = {
        sts = "${local.localstack_endpoint}"
        s3 = "${local.localstack_endpoint}"
      }
    }
}

```
You can use the `root.hcl` file on this repo and make changes as you see fit. 
The `region` value is retrieved from the `config.hcl` file, which terragrunt use dynamically to distribute the module configurations (terraform files) into the region directory by each service and into their environment(s). To understand this, clone the repo, run `terragrunt stack generate` from any of the region directory and check the `.terragrunt-stack` directory.


```sh
  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("config.hcl"))

  # extract the variables
  aws_region = local.region_vars.locals.aws_region
```
The `provider.tf` is also generated at runtime for any region(s) and service(s) you want to provision. DON'T REPEAT YOURSELF! 

### The `config.hcl` file
```sh
locals {
    aws_region = region     # "us-west-2"
    base_repo = module_url  # "git::https://github.com/eedygreen/Infrastruture-As-Code-modules.git"

                            # you can chose to deploy different or same version for different services
    versions = {
        cluster = "v0.1.0-patch.2" 
        s3 = "v0.1.1-beta.1"
        ingress = "v0.1.1-beta"
        app = "v0.1.0-patch.1" 
        dev = "v0.1.0"      # version for environment (dev, prod..) must correspond to release version as others
        prod = "v0.1.0"
    }

    cluster_source = "${local.base_repo}//units/cluster?ref=${local.versions.cluster}"
    ingress_source = "${local.base_repo}//units/ingress?ref=${local.versions.ingress}"
    s3_source = "${local.base_repo}//units/s3?ref=${local.versions.s3}"
    app_source = "${local.base_repo}//units/app?ref=${local.versions.app}"
}
```
Change the aws_region and versions as you wish. 

### Terragrunt Stack Configuration `terragrunt.stack.hcl` file
```sh

locals {
  units_path = read_terragrunt_config(find_in_parent_folders("config.hcl"))
}

unit "dev" {
  source = "${local.units_path.locals.cluster_source}"
  path = "dev"
  values = {
    ** redacted for brevity
  }
}

unit "prod" {
  source = "${local.units_path.locals.cluster_source}"
  path = "prod"
  values = {
    ** redacted for brevity
  }
}

```
The stack `terragrunt.stack.hcl` is where you define the services to be provisioned. 
The cluster example is or provisioning of `dev` and `prod` environment. Check the relavant regional directory if you want to see the complete configuration of the `terragrunt.stack.hcl`.


### Terragrunt Deployment by Region

#### Deploy Individual Region (Reduce Blast Radius)
To deploy infrastructure in a specific region:

```sh
# Navigate to the region-specific directory
cd environments/us-east-1/prod

# Plan changes
terragrunt plan

# Apply changes
terragrunt apply

                OR
terragrunt plan -all --working-dir dir_path

terragrunt apply -all -working-dir dir_path
```

Advantages:
- Minimize Blast Radius (risk during deployments)
- Allows for region-specific configurations

Disadvantage
- Limits the scope of changes to a specific region(s)

#### Deploy All Regions Simultaneously
To deploy infrastructure across all regions in environments directory such as the above with three regions 

```bash
# From the environments directory
cd environments

# Plan all changes
terragrunt run-all plan

# Apply all changes
terragrunt run-all apply
```

Advantages:
- Parallel deployment across regions
- Apply global configuration changes at once such as patches or updating helm charts versions

Disadvantage
- Maximize Blast Radius (risk during deployment)

```sh 
Blast Radius is the measure of potential damage or disruption that can be caused by the failure or compromise of a single component within a larger system.
```
### Best Practices
1. Always run `plan` before `apply`
2. Use workspaces to isolate environments
3. Implement proper state locking
4. Follow least privilege principle
5. Use consistent tagging across resources

## Testing
This project includes integration tests using Terratest. To run the tests:

```bash
cd test
go test -v -p 1 ./...
```

## Contributing
Follow this instructions if you will like to contribute to repo. 
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

