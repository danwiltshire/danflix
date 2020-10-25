# frozen_string_literal: true

require 'spec_helper'

#describe apigateway('danflix-test-api') do
#  it { should exist }
#end

describe secretsmanager('danflix-test-cloudfront') do
  it { should exist }
  its(:rotation_enabled) { should eq nil }
end


#my_ec2_instance = `AWS_PROFILE=default terraform output function_getsignedcookie_name`.strip

describe lambda("danflix-test-getsignedcookie") do
  it { should exist }
  its ('handler') { should eq 'index.handler'}
  its ('version') { should eq '$LATEST' }
  its ('runtime') { should eq 'nodejs12.x' }
  it { should have_env_var_value("REGION", "eu-west-2") }
  it { should have_env_var_value("SECRET_NAME", "danflix-test-cloudfront") }
end

["danflix-test-media", "danflix-test-webapp"].each do | bucket |
  describe s3_bucket("#{bucket}") do
    it { should exist }
    it { should_not have_versioning_enabled }
    its( :acl_grants_count ) { should eq 1 }
  end
end