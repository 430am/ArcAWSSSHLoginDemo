# Declare TF variables
variable "server_count" {
  default = 1
}

variable "aws_region" {
  default = "us-west-2"
}
variable "aws_availabilityzone" {
  default = "us-west-2a"
}

variable "azure_location" {
  default = "westus2"
}

variable "hostname" {
  default = "aws-server"
}

variable "azure_resource_group" {
  default = "rg-Arc-AWS-Demo"
}

variable "subscription_id" {
}

variable "client_id" {
}

variable "client_secret" {
  sensitive = true
}

variable "tenant_id" {
}
