#!/bin/bash

# Build and deploy script for infrastructure and webapp

set -e

# User variables
ENVIRONMENT="$1"
TF_CLOUD_API_TOKEN="$TF_CLOUD_API_TOKEN"

# System variables
export TF_IN_AUTOMATION=true
export AWS_DEFAULT_PROFILE="$ENVIRONMENT"

function log_usage() {
  echo ""
  echo "Usage: ./deploy.sh ENVIRONMENT"
  echo ""
  echo "Example AWS credential configuration (profile name should match ENVIRONMENT):"
  echo ""
  echo "~/.aws/config"
  echo "  [default]"
  echo "  region=eu-west-1"
  echo ""
  echo "  [profile prod]"
  echo "  role_arn=arn:aws:iam::012345678901:role/AccessRole"
  echo "  region=eu-west-1"
  echo "  source_profile=default"
  echo ""
  echo "~/.aws/credentials"
  echo "  [default]"
  echo "  aws_access_key_id=ABCABCABCABCABCABCABC"
  echo "  aws_secret_access_key=abcABCabcABCabcABCabcABCabcABCabcABCabcABC"
}

log_usage && exit 1

echo "[INFO] Chosen environment is $ENVIRONMENT. This value should be reflected as a profile in your ~/.aws/config file"

# Validate critical variables are set
[[ -z "$TF_CLOUD_API_TOKEN" ]] && echo "[ERROR] TF_CLOUD_API_TOKEN is not set. Visit https://app.terraform.io/app/settings/tokens to create an API token." && log_usage && exit 1

# Validate AWS credentials
echo "[DEBUG] AWS caller identity:"
aws sts get-caller-identity | jq

(cd infra/terraform && terraform init -backend-config="token=${TF_CLOUD_API_TOKEN}" -var "TF_CLOUD_API_TOKEN=$TF_CLOUD_API_TOKEN")
(cd infra/terraform && terraform plan -var "environment=$ENVIRONMENT")
(cd infra/terraform && terraform apply -var "environment=$ENVIRONMENT")

# Get Terraform outputs as JSON so we can pick individual key values
TF_OUTPUT="$(cd infra/terraform && terraform output -json)"

# The webapp build process expects these environment variables to be set
export REACT_APP_AUTH0_DOMAIN="$(echo $TF_OUTPUT | jq -r '.auth_domain .value')"
export REACT_APP_AUTH0_CLIENT_ID="$(echo $TF_OUTPUT | jq -r '.auth_client_id .value')"
export REACT_APP_AUTH0_AUDIENCE="$(echo $TF_OUTPUT | jq -r '.api_endpoint .value')"
export WEBAPP_BUCKET_NAME="$(echo $TF_OUTPUT | jq -r '.private_storage_webapp_id .value')"

[[ -z "$REACT_APP_AUTH0_DOMAIN" ]] && echo "[ERROR] REACT_APP_AUTH0_DOMAIN is not valid. Ensure the Terraform output 'auth_domain' is set." && log_usage && exit 1
[[ -z "$REACT_APP_AUTH0_CLIENT_ID" ]] && echo "[ERROR] REACT_APP_AUTH0_CLIENT_ID is not valid. Ensure the Terraform output 'auth_client_id' is set." && log_usage && exit 1
[[ -z "$REACT_APP_AUTH0_AUDIENCE" ]] && echo "[ERROR] REACT_APP_AUTH0_AUDIENCE is not valid. Ensure the Terraform output 'api_endpoint' is set." && log_usage && exit 1
[[ -z "$WEBAPP_BUCKET_NAME" ]] && echo "[ERROR] WEBAPP_BUCKET_NAME is not valid. Ensure the Terraform output 'private_storage_webapp_id' is set." && log_usage && exit 1

echo "[INFO] Building the webapp"
(cd webapp && npm i)
(cd webapp && npm run build)

echo "[INFO] Uploading the build webapp to s3://$WEBAPP_BUCKET_NAME"
aws s3 sync webapp/build/ "s3://$WEBAPP_BUCKET_NAME/" --delete

echo "[DONE] Deployed."
