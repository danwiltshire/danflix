# frozen_string_literal: true

# Examples found here: https://github.com/BensamV/kitchen-terraform-aws

control "private_storage" do
  ["private_storage_media_id", "private_storage_webapp_id"].each do | attribute |
    describe aws_s3_bucket(bucket_name: "#{attribute(attribute)}") do
      it { should exist }
      it { should_not be_public }
      its( 'bucket_acl.count' ) { should eq 1 }
      its( 'bucket_policy' ) { should be_empty }
    end
  end
end
