# frozen_string_literal: true

control "url_check" do
  describe http('https://www.google.co.uk') do
    its('status') { should cmp 200 }
  end
end
  