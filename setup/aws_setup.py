'''
Create AWS account relationships
'''

import uuid
import boto3
import json
import logging
import argparse
from string import Template
from botocore.exceptions import ClientError
from typing import TypedDict

parser = argparse.ArgumentParser()
parser.add_argument('--replaceparentaccesskeys', action='store_true', help='replace existing parent access keys')
args = parser.parse_args()

#
# Config
#
class ConfigDictionary(TypedDict):
  region: str
  access_key: str
  secret_key: str
  username: str
  bucket_name: str
  dynamodb_table_name: str
  state_write_policy: str
  name: str
  template: str

with open('config.json') as json_file:
  config: ConfigDictionary = json.load(json_file)

#
# Utilities
#
def string_substitute(template: str, dictionary: dict):
  '''Takes in a file 'template' and dictionary 'dictionary', returns the string-substituted template'''
  with open(template) as t:
    return Template(t.read()).substitute(dictionary)

#
# App functions
#
def create_bucket(bucket_name: str, region: str, access_key: str, secret_key: str):
  try:
    s3_client = boto3.client('s3',
      region_name=region,
      aws_access_key_id=access_key,
      aws_secret_access_key=secret_key
      )
    location = {'LocationConstraint': region}
    s3_client.create_bucket(
      Bucket=bucket_name,
      CreateBucketConfiguration=location,
      ACL='private'
      )
  except ClientError as e:
    logging.error(e)
    return False

def enable_bucket_versioning(bucket_name: str, access_key: str, secret_key: str):
  try:
    s3_client = boto3.client('s3',
      aws_access_key_id=access_key,
      aws_secret_access_key=secret_key
      )
    s3_client.put_bucket_versioning(
      Bucket=bucket_name,
      VersioningConfiguration={'Status': 'Enabled'}
      )
  except ClientError as e:
    logging.error(e)
    return False

def create_dynamodb_table(table_name: str, region: str, access_key: str, secret_key: str):
  try:
    client = boto3.client('dynamodb',
      region_name=region,
      aws_access_key_id=access_key,
      aws_secret_access_key=secret_key
      )
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
    logging.error(e)
    return False


def create_iam_policy(name: str, template: str, access_key: str, secret_key: str):
  try:
    client = boto3.client('iam',
      aws_access_key_id=access_key,
      aws_secret_access_key=secret_key
      )
    client.create_policy(
      PolicyName=name,
      PolicyDocument=template
      )
  except ClientError as e:
    logging.error(e)
    return False

def create_iam_user(username: str, access_key: str, secret_key: str):
  try:
    client = boto3.client('iam',
      aws_access_key_id=access_key,
      aws_secret_access_key=secret_key
      )
    client.create_user(
      UserName=username
      )
  except ClientError as e:
    logging.error(e)
    return False

def attach_user_policy(username: str, policy_arn: str, access_key: str, secret_key: str):
  try:
    client = boto3.client('iam',
      aws_access_key_id=access_key,
      aws_secret_access_key=secret_key
      )
    client.attach_user_policy(
      UserName=username,
      PolicyArn=policy_arn
      )
  except ClientError as e:
    logging.error(e)
    return False

def create_access_key(username: str, access_key: str, secret_key: str) -> dict:
  try:
    client = boto3.client('iam',
      aws_access_key_id=access_key,
      aws_secret_access_key=secret_key
      )
    res = client.create_access_key(
      UserName=username
      )
    return res
  except ClientError as e:
    logging.error(e)
    return False

def list_access_keys(username: str, access_key: str, secret_key: str) -> dict:
  try:
    client = boto3.client('iam',
      aws_access_key_id=access_key,
      aws_secret_access_key=secret_key
      )
    res = client.list_access_keys(
      UserName=username
      )
    return res
  except ClientError as e:
    logging.error(e)
    return False

def delete_access_key(username: str, access_key_id: str, access_key: str, secret_key: str) -> dict:
  try:
    client = boto3.client('iam',
      aws_access_key_id=access_key,
      aws_secret_access_key=secret_key
      )
    res = client.delete_access_key(
      UserName=username,
      AccessKeyId=access_key_id
      )
    return res
  except ClientError as e:
    logging.error(e)
    return False

def create_iam_role(role_name: str, policy: str, access_key: str, secret_key: str):
  try:
    client = boto3.client('iam',
      aws_access_key_id=access_key,
      aws_secret_access_key=secret_key
      )
    client.create_role(
      RoleName=role_name,
      AssumeRolePolicyDocument=policy
    )
  except ClientError as e:
    logging.error(e)
    return False

def get_iam_role(role_name: str, access_key: str, secret_key: str):
  try:
    client = boto3.client('iam',
      aws_access_key_id=access_key,
      aws_secret_access_key=secret_key
      )
    res = client.get_role(
      RoleName=role_name
    )
    return res
  except ClientError as e:
    logging.error(e)
    return False

def attach_role_policy(role_name: str, policy_arn: str, access_key: str, secret_key: str):
  try:
    client = boto3.client('iam',
      aws_access_key_id=access_key,
      aws_secret_access_key=secret_key
      )
    client.attach_role_policy(
      RoleName=role_name,
      PolicyArn=policy_arn
    )
  except ClientError as e:
    logging.error(e)
    return False

#
# Logic
#
# Create the state bucket
create_bucket(
  config['aws']['resources']['parent']['bucket_name'],
  config['aws']['region'],
  config['aws']['credentials']['parent']['access_key'],
  config['aws']['credentials']['parent']['secret_key']
  )

# Enable state bucket versioning
enable_bucket_versioning(
  config['aws']['resources']['parent']['bucket_name'],
  config['aws']['credentials']['parent']['access_key'],
  config['aws']['credentials']['parent']['secret_key']
  )

# Create the state locking mechanism
create_dynamodb_table(
  config['aws']['resources']['parent']['dynamodb_table_name'],
  config['aws']['region'],
  config['aws']['credentials']['parent']['access_key'],
  config['aws']['credentials']['parent']['secret_key']
  )

# Create the state write policy
state_write_policy = string_substitute(
  config['aws']['resources']['parent']['state_write_policy']['template'],
  dict(
    state_bucket = config['aws']['resources']['parent']['bucket_name'],
    state_table = config['aws']['resources']['parent']['dynamodb_table_name']
    )
  )
create_iam_policy(
  config['aws']['resources']['parent']['state_write_policy']['name'],
  state_write_policy,
  config['aws']['credentials']['parent']['access_key'],
  config['aws']['credentials']['parent']['secret_key']
  )

# Create the global ops user
create_iam_user(
  config['aws']['resources']['parent']['username'],
  config['aws']['credentials']['parent']['access_key'],
  config['aws']['credentials']['parent']['secret_key']
  )

# Attach tfstate_write policy to global ops user
arn: str = "arn:aws:iam::{account_id}:policy/danflix-tfstate-write".format(
  account_id = config['aws']['resources']['parent']['account_id']
  )
attach_user_policy(
  config['aws']['resources']['parent']['username'],
  arn,
  config['aws']['credentials']['parent']['access_key'],
  config['aws']['credentials']['parent']['secret_key']
)

# Create policies allowing danflix-global-ops to assume child roles
for child_account in config['aws']['resources']['child_accounts']:
  state_write_policy: str = string_substitute(
    config['aws']['resources']['parent']['assume_role_policy']['template'],
    dict(
      child_account_id = child_account['account_id'],
      child_account_role = child_account['role_name']
      )
    )

  policy_name: str = "allow-assumerole-{role_name}".format(
    role_name = child_account['role_name']
    )
  create_iam_policy(
    policy_name,
    state_write_policy,
    config['aws']['credentials']['parent']['access_key'],
    config['aws']['credentials']['parent']['secret_key']
    )
  # Attach tfstate_write policy to global ops user
  arn: str = "arn:aws:iam::{account_id}:policy/{policy_name}".format(
    account_id = config['aws']['resources']['parent']['account_id'],
    policy_name = policy_name
    )
  attach_user_policy(
    config['aws']['resources']['parent']['username'],
    arn,
    config['aws']['credentials']['parent']['access_key'],
    config['aws']['credentials']['parent']['secret_key']
  )

# Create child role danflix-[env]-ops users, assign AdministratorAccess,
# allow role to be assumed by parent danflix-global-ops account.
for child_account in config['aws']['resources']['child_accounts']:
  assume_role_policy: str = string_substitute(
    config['aws']['resources']['parent']['assume_role_with_ext_id_policy']['template'],
    dict(
      parent_account_id=config['aws']['resources']['parent']['account_id'],
      parent_account_username=config['aws']['resources']['parent']['username'],
      external_id=uuid.uuid4()
      )
    )
  create_iam_role(
    child_account['role_name'],
    assume_role_policy,
    config['aws']['credentials'][child_account['environment']]['access_key'],
    config['aws']['credentials'][child_account['environment']]['secret_key']
    )
  attach_role_policy(
    child_account['role_name'],
    "arn:aws:iam::aws:policy/AdministratorAccess",
    config['aws']['credentials'][child_account['environment']]['access_key'],
    config['aws']['credentials'][child_account['environment']]['secret_key']
    )
  role = get_iam_role(
    child_account['role_name'],
    config['aws']['credentials'][child_account['environment']]['access_key'],
    config['aws']['credentials'][child_account['environment']]['secret_key']
    )
  external_id = role['Role']['AssumeRolePolicyDocument']['Statement'][0]['Condition']['StringEquals']['sts:ExternalId']
  print("Allowed ExternalId for {}: {}".format(child_account['role_name'], external_id))

# Global ops user access keys
if args.replaceparentaccesskeys:
  keys = list_access_keys(
    config['aws']['resources']['parent']['username'],
    config['aws']['credentials']['parent']['access_key'],
    config['aws']['credentials']['parent']['secret_key']
    )
  for key in keys['AccessKeyMetadata']:
    delete_access_key(
      config['aws']['resources']['parent']['username'],
      key['AccessKeyId'],
      config['aws']['credentials']['parent']['access_key'],
      config['aws']['credentials']['parent']['secret_key']
      )
  # Create API access credentials or global ops user
  credentials: str = create_access_key(
    config['aws']['resources']['parent']['username'],
    config['aws']['credentials']['parent']['access_key'],
    config['aws']['credentials']['parent']['secret_key']
    )
  # Print the credentials
  if credentials:
    print(credentials['AccessKey']['UserName'] + " credentials:")
    print("AccessKeyId: " + credentials['AccessKey']['AccessKeyId'])
    print("SecretAccessKey: " + credentials['AccessKey']['SecretAccessKey'])
else:
  # Create API access credentials or global ops user
  credentials: str = create_access_key(
    config['aws']['resources']['parent']['username'],
    config['aws']['credentials']['parent']['access_key'],
    config['aws']['credentials']['parent']['secret_key']
    )
  # Print the credentials
  if credentials:
    print(credentials['AccessKey']['UserName'] + " credentials:")
    print("AccessKeyId: " + credentials['AccessKey']['AccessKeyId'])
    print("SecretAccessKey: " + credentials['AccessKey']['SecretAccessKey'])
