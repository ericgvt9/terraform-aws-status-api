# Serverless Status API

This module implements an AWS Lambda function and API Gateway to deploy two functions to get and set status of an object referenced by an id.

## Inputs

| Name                    | Description                                |  Type  |     Default      | Required |
| ----------------------- | ------------------------------------------ | :----: | :--------------: | :------: |
| module_name             | Name of this module                        | string |   `status_api`   |    no    |
| aws_credentials_profile | Profile used to deploy this infrastructure | string |    `default`     |    no    |
| aws_region              | AWS region to deploy the infrastructure to | string | `ap-southeast-1` |    no    |
| stage                   | Stage to deploy to on AWS Gateway          | string |      `dev`       |    no    |

## Deployment

1. Install [Terraform](https://www.terraform.io/downloads.html)

2. Create a file `main.tf` with the following deployment

```
module "status-api" {
  source  = "Open-Attestation/status-api/aws"
  version = "0.0.5"
}
output "endpoint_url" {
  value = "${module.status-api.invoke_url}"
}

output "api_key" {
  value = "${module.status-api.api_key}"
}

```

3. Run `terraform init` to initialise terraform

4. Run `terraform apply` to deploy the infrastructure. When prompted if you want to apply the changes, enter `yes`
