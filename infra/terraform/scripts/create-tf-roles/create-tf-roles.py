# Initialises the backend state environment for Terraform.

# Use aws configure to set credentials.

# terraform init -backend-config="bucket=danflix-tfstate" -backend-config="region=eu-west-2" -backend-config="key=tfstate"

import os
import hcl2
import pprint
import logging
import boto3
from botocore.exceptions import ClientError

"""with open('../terraform.tfvars') as file:
    dict = hcl2.load(file)
    for environments in dict['aws_provider_configuration']:
        for environment in environments:
            print("Found environment " + environment)
            print(environments[environment]['access_key'])
            print(environments[environment]['secret_key'])
            print(environments[environment]['region'])"""


def create_bucket(bucket_name, region):

    iam = boto3.resource('iam')
    role = iam.Role('danflix-terraform')

    # Create bucket
    try:
        print("hello world")
    except ClientError as e:
        logging.error(e)
        return False


create_bucket("danflix-tfstate", "eu-west-2")
