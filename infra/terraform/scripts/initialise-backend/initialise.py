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

    # Create bucket
    try:
        s3_client = boto3.client('s3', region_name=region)
        location = {'LocationConstraint': region}
        s3_client.create_bucket(
            Bucket=bucket_name,
            CreateBucketConfiguration=location,
            ACL='private')
    except ClientError as e:
        if e.response['Error']['Code'] == 'BucketAlreadyOwnedByYou':
            print("Bucket " + bucket_name + " already exists.")
            return True
        else:
            logging.error(e)
            return False

def enable_bucket_versioning(bucket_name):

    # Enable bucket versioning
    try:
        s3 = boto3.resource('s3')
        bucket_versioning = s3.BucketVersioning(bucket_name)
        bucket_versioning.enable()
    except ClientError as e:
        logging.error(e)
        return False

def create_dynamodb_table(table_name, region):

    # Create DynamoDB table
    try:
        client = boto3.client('dynamodb', region_name=region)
        client.create_table(
            AttributeDefinitions=[
                {
                    'AttributeName': 'LockID',
                    'AttributeType': 'S'
                }
            ],
            TableName=table_name,
            KeySchema=[
                {
                    'AttributeName': 'LockID',
                    'KeyType': 'HASH'
                },
            ],
            ProvisionedThroughput={
                'ReadCapacityUnits': 1,
                'WriteCapacityUnits': 1
            }
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceInUseException':
            print("DynamoDB table " + table_name + " already exists.")
            return True
        else:
            logging.error(e)
            return False

create_bucket("danflix-tfstate", "eu-west-2")
enable_bucket_versioning("danflix-tfstate")
create_dynamodb_table("danflix-tfstate", "eu-west-2")
