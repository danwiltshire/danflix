import os
import hcl2
import pprint
import logging
import boto3
from botocore.exceptions import ClientError

with open('../terraform.tfvars') as file:
    dict = hcl2.load(file)
    for environments in dict['aws_provider_configuration']:
        for environment in environments:
            print("Found environment " + environment)
            print(environments[environment]['access_key'])
            print(environments[environment]['secret_key'])
            print(environments[environment]['region'])
