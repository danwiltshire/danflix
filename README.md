# danflix

An alternative take on Plex/Netflix.

Pulls in video content from an external source and caches it on AWS S3 for fast and reliable on-demand playback.  Auto deletes played video from S3 to reduce storage costs.

## Deploying

Currently the backend is deployed via Terraform and the frontend is deployed manually.

### Prerequisites

1. Create a dedicated AWS account (recommended)
2. Setup AWS billing alerts (recommended)
3. Connect AWS account to an organisation for central management (optional)
4. Create AWS IAM user for programmatic access (recommended)
5. Attach the relavant AWS IAM policies or roles to the new user
6. Populate `backend/terraform.tfvars` with the AWS access key and secret key
7. Create an Auth0 account
8. Create a dedicated Auth0 tenant (optional)
9. Create an Auth0 'Machine to Machine' application for Terraform:
    * API: Auth0 Management API
    * Scopes: All (not ideal, could be locked down)
10. Populate `backend/terraform.tfvars` with the `domain` (Auth0 tenant), `client_id` and `client_secret`
11. Create a CloudFront key pair, populate private key in terraform.tfvars.
