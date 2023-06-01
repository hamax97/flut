require "astrum"

# Additional features presented here:
# 1. complex load_policy
# 2. config.cookie_manager
# 3. config.results.real_time_results
# 4. config to specific "user journey" (and its included "user journeys") and specific request
# 5. reuse of "user journeys".

Astrum.config do |config|
  config.vars[:main_url] = "https://some-staging-website.com" # these are shared among threads.

  config.cookie_manager = true # enabled by default.

  config.results
    .output_csv("results.csv")
    .summary(:stdout) # this is default.
    .real_time_results(:influxdb, "http://influxdb:8086")

  config.expectations do
    thresholds # apply to all requests; note this is http agnostic.
      .response_time_ms(2000)
      .data_received_bytes(1024)

    expect # I could use RSpec for these kind of things.
      .all_requests.are_expected_to respond_with(:valid_status_code)
  end
end

load_policy = {
  target_rps: [ # spike test.
    { rps: 10, duration: "10s" },
    { rps: 100, duration: "60s" },
    { rps: 150, duration: "5s" },
    { rps: 100, duration: "60s" },
    { rps: 150, duration: "5s" },
    { rps: 100, duration: "60s" },
    { rps: 10, duration: "10s" },
  ],
  max_users: 20,
}

Astrum.execute load_policy: load_policy do
  main_url = config.vars[:main_url]

  output = execute :login
  execute :add_to_cart, input: output

  get "#{main_url}/some/other/endpoint", headers: { "x-dynatrace-header" => "some id"}
end

# this can be defined in another file, then included wherever you want.
Astrum.describe :login do
  # this applies to all requests under :login unless it's overridden,
  # even applies to other "user journeys" executed here.
  config.expectations do
    thresholds.response_time_ms(500)
  end

  main_url = config.vars[:main_url]
  get main_url

  # automatically follow redirects, like a browser, add the endpoints followed to the results.
  # how to extract information from the redirected endpoints?

  credentials = csv_read("users.csv").next

  post "#{main_url}/login", body: build_credentials_body(credentials)

  # extract token from response perhaps
  token

  # maybe setting a config for all "user journeys" tagged.
  config.http
    .for_tags(:needs_authorization)
    .set_header("authorization").with("Bearer #{token}")

  # or just returning the token
  # token
end

Astrum.describe :add_to_cart, tags: {needs_authorization: true} do |input|
  main_url = config.vars[:main_url]

  # all requests will be authorized if :login was executed successfully
  post "#{main_url}/cart", body: body do
    # how to make this override the global assertion for all requests?
    expect(response.status_code).to be 201

    # how to make this override the global threshold or the one set in the upper level.
    thresholds.response_time_ms(3000)
  end
end
