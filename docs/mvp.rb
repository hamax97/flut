# frozen_string_literal: true

require "flut"
require "json"

URL = "https://my-url.com"

load_policy = {
  target_rps: [
    { rps: 5, duration: "10s" },
    { rps: 20, duration: "30s" },
    { rps: 5, duration: "10s" }
  ],
  max_users: 10
}

Flut.execute load_policy: do
  res = post "#{URL}/login", body: { username: "test_user", password: "test_password" }
  token = extract_token(res)

  post "#{URL}/buy-book",
       body: { book_name: "The Silmarillion" },
       headers: { authorization: "Bearer #{token}" }
end

def extract_token(res)
  res_body = JSON.parse(res.body)
  res_body["token"]
end
