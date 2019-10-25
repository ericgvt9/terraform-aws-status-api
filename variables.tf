variable "aws_credentials_profile" {
  type        = "string"
  default     = "default"
  description = "Profile used to deploy this infrastructure"
}

variable "aws_region" {
  type        = "string"
  default     = "ap-southeast-1"
  description = "AWS region to deploy the infrastructure to"
}

variable "module_name" {
  type        = "string"
  default     = "status_api"
  description = "Name of this module"
}

variable "stage" {
  type        = "string"
  default     = "dev"
  description = "Stage to deploy to on AWS Gateway"

}
