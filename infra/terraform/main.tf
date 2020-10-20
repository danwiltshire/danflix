provider "aws" {
  profile    = terraform.workspace
  // Specify region because Terraform ignores region in ~/.aws/config
  region     = var.aws_provider_configuration[terraform.workspace]["region"]
}

terraform {
  backend "s3" {}
}

locals {
  resource_prefix = "${var.application_name}-${terraform.workspace}"
}

/**
 * # Webapp storage
*/
module "private_storage_webapp" {
  source          = "./modules/private_storage"
  storage_name    = "webapp"
  resource_prefix = local.resource_prefix
}

/**
 * # Media storage
*/
module "private_storage_media" {
  source          = "./modules/private_storage"
  storage_name    = "media"
  resource_prefix = local.resource_prefix
}

/**
 * # Media access
*/
/*module "iam_role_policy_lambda_media_access" {
  source          = "./modules/iam_role_policy"
  role_name       = "allow-read-media"
  role_template   = file("./modules/iam_role_policy/templates/allow_lambda_assume.json")
  policy_name     = "allow-read-media"
  policy_template = templatefile("./modules/iam_role_policy/templates/allow_read_bucket.json.tmpl", { bucket_name = module.private_storage_media.id })
  resource_prefix = local.resource_prefix
}*/

/**
 * # Get signed cookies
*/
module "iam_role_policy_lambda_media_access" {
  source          = "./modules/iam_role_policy"
  role_name       = "allow-read-media"
  role_template   = file("./modules/iam_role_policy/templates/allow_lambda_assume.json")
  policy_name     = "allow-read-media"
  policy_template = templatefile("./modules/iam_role_policy/templates/allow_read_bucket.json.tmpl", { bucket_name = module.private_storage_media.id })
  resource_prefix = local.resource_prefix
}
