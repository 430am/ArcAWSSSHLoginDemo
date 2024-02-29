#!/bin/sh

#<--- Change the following environment variables according to your Azure service principal and AWS project details --->
export TF_VAR_subscription_id=<Azure Subscription ID>
export TF_VAR_client_id=<Azure Service Principal ID>
export TF_VAR_client_secret=<Azure Service Principal Secret>
export TF_VAR_tenant_id=<Azure Entra Tenant ID>
export AWS_ACCESS_KEY_ID=<AWS IAM User Access Key>
export AWS_SECRET_ACCESS_KEY=<AWS IAM User Access Secret>