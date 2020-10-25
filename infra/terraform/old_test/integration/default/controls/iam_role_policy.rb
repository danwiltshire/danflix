# frozen_string_literal: true

control "iam_role_policy" do
  ["iam_role_policy_getsignedcookie_role_name"].each do | attribute |
    describe aws_iam_role(role_name: "#{attribute(attribute)}") do
      it { should exist }
    end
  end
  ["iam_role_policy_getsignedcookie_policy_name"].each do | attribute |
    describe aws_iam_policy(policy_name: "#{attribute(attribute)}") do
      it { should exist }
      it { should be_attached_to_role("#{attribute("iam_role_policy_getsignedcookie_role_name")}") }
      it { should_not have_statement('Effect' => 'Allow', 'Resource' => '*', 'Action' => '*')}
      it { should have_statement(Effect: 'Allow', Action: 'secretsmanager:GetSecretValue')}
      it { should have_statement(Effect: 'Allow', Action: 'kms:Decrypt')}
      it { should have_statement(Effect: 'Allow', Action: 'logs:CreateLogGroup')}
      it { should have_statement(Effect: 'Allow', Action: 'logs:CreateLogStream')}
      it { should have_statement(Effect: 'Allow', Action: 'logs:PutLogEvents')}
    end
  end
end
