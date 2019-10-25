# Serverless Status API

This module implements an AWS Lambda function and API Gateway to deploy two functions to get and set status of an object referenced by an id.

## Inputs

| Name                    | Description                                |  Type  |     Default      | Required |
| ----------------------- | ------------------------------------------ | :----: | :--------------: | :------: |
| module_name             | Name of this module                        | string |   `status_api`   |    no    |
| aws_credentials_profile | Profile used to deploy this infrastructure | string |    `default`     |    no    |
| aws_region              | AWS region to deploy the infrastructure to | string | `ap-southeast-1` |    no    |
| stage                   | Stage to deploy to on AWS Gateway          | string |      `dev`       |    no    |
