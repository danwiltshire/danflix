# frozen_string_literal: true

control "function" do
  ["function_getsignedcookie_name"].each do | attribute |
    describe aws_lambda("#{attribute(attribute)}") do
      it { should exist }
      its ('handler') { should eq 'index.handler'}
      its ('version') { should eq '$LATEST' }
      its ('runtime') { should eq 'nodejs12.x' }
    end
  end
end
