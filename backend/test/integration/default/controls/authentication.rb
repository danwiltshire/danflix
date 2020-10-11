# frozen_string_literal: true

control "url_check" do
  describe http('https://dwlab.eu.auth0.com/oauth/token',
                method: 'POST',
                headers: {'Content-Type' => 'application/json'},
                data: '{"client_id":"x","client_secret":"x","audience":"x","grant_type":"client_credentials"}') do
    its('status') { should cmp 200 }
    its('body') { should match '\"token_type\":\"Bearer\"' }
  end
end
