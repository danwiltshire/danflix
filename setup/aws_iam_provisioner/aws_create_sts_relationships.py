'''
Create AWS account relationships using AWS STS assume role

Prerequisites:
- AWS credentials must be configured either as environment variables or ~/.aws/credentials

Usage:
python3 aws_create_sts_relationships.py [parent_account_id] [parent_account_user_name]
'''

import os
import uuid
import argparse
from string import Template

parser = argparse.ArgumentParser(description='Create AWS account relationships.')
parser.add_argument('parent_account_id',
  type=str,
  help='The parent AWS account ID'
  )
parser.add_argument('parent_account_user_name',
  type=str,
  help='The parent AWS IAM user name trusted to assume a role in the child account'
)
args = parser.parse_args()

def string_substitute(tmpl, dict):
  '''Takes in a file tmpl and dictionary dict, returns the string-substituted tmpl'''
  with open(tmpl) as tmpl:
    return Template(tmpl.read()).substitute(
      parent_account_id=args.parent_account_id,
      parent_account_user_name=args.parent_account_user_name,
      sts_externalid=uuid.uuid4()
    )

print(string_substitute('./templates/sts_assumerole.json.tmpl',
  dict(
    parent_account_id=args.parent_account_id,
    parent_account_user_name=args.parent_account_user_name,
    sts_externalid=uuid.uuid4()
  )
))
