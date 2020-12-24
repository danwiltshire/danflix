# frozen_string_literal: true

# Each API path should return 401 when unauthenticated
["listobjects", "presignedurl"].each do |path|
  control "Unauthenticated call to /#{path}" do
    describe http("#{attribute("api_invoke_url")}#{path}") do
      its('status') { should cmp 401 }
      its('body') { should match '{"message":"Unauthorized"}' }
    end
  end
end
