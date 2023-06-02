require 'diluvium'

# Features presented here:
# 1. config object
# 2. config.vars object to share variables among threads.
# 3. config.thresholds
# 4. config.http
# 5. load_policy hash to configure the execution of a test.
# 6. Diluvium.execute to start a test.
#    - How about executing in concurrently? So, allow multiple Diluvium.execute.

Diluvium.config do |config|
  config.vars[:main_url] = "https://some-staging-website.com" # these are shared among threads.

  config
    .results
    .output_csv("results.csv")
    .summary(:stdout) # this is default.

  config.thresholds # apply to all requests; note this is http agnostic.
    .response_time_ms(2000)
    .data_received_bytes(1024)

  config.http # I could use RSpec for these kind of things.
    .all_requests.are_expected_to respond_with(:valid_status_code)
end

load_policy = {
  target_rps: 100,
  max_users: 10,
  duration_sec: 300
}

Diluvium.execute load_policy: load_policy do
  main_url = config.vars[:main_url]

  get main_url
end

# execute:
# ruby simple_test.rb

# this could be changed to use my own CLI.
# astrum [options] simple_test.rb