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

def parse_template(template, dict):
  with open(template) as template:
    return Template(template.read()).substitute(
      parent_account_id=args.parent_account_id,
      parent_account_user_name=args.parent_account_user_name,
      sts_externalid=uuid.uuid4()
    )

print(parse_template('./templates/sts_assumerole.json.tmpl',
  dict(
    parent_account_id=args.parent_account_id,
    parent_account_user_name=args.parent_account_user_name,
    sts_externalid=uuid.uuid4()
  )
))
