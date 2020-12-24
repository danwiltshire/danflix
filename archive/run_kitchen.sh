#!/bin/bash

current_workspace=$(terraform workspace show)
bundler exec kitchen converge
export AWS_PROFILE=kitchen-terraform-default-aws
bundler exec kitchen verify
unset AWS_PROFILE
bundler exec kitchen destroy
terraform workspace select $current_workspace
