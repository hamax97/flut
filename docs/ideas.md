# Description

Distributed performance testing tool written in Ruby.

NAME TO BE DEFINED, Astrum IS NOT COOL. Options:

- Diluvium
- Ruvium (There's already rubium)
- What did the ancient people yieled when they started a battle?
- Reluge
- Flut (Flood in German)

## Features

- DSL to easily define human-readable testplans (think of RSpec):
  - Reusable user journeys (group of requests).
  - Example: it's able to define the login. This login will then be reused by other user
    journeys.

- Able to do TPS-centered executions.
  - Instead of defining threads, define the target TPS.
  - This should be configurable per user journey.

- Able to do thread-centered executions.
  - Configurable per user journey.

- Able to execute distributedly:
  - Define the pool of servers.
  - Execute different user journes from different servers based on a defined load pattern.
  - Able to collect results from all servers easily.
  - Using SSH ??

- Results:
  - Summary results in multiple formats:
    - Like k6 in stdout.
    - In CSV.
    - Integrate with InfluxDB. (Enable more integrations)
  - Detailed results:
    - In CSV.
    - Integrate with InfluxDB. (Enable more integrations)

- Decouple from HTTP webservers, have the capacity to interact with Kafka/RabbitMQ/RPC ...

- Translate from HAR files to user journeys.
  - How to hide all the stuff that comes in a HAR file (headers).

- Able to define global configs for all requests:
  - Headers
  - Cookies
  - Thresholds (to mark the request as passed or not)
  - Assertions

- Able to define configs specific to each request:

- Able to set sleeping times:
  - Constant.
  - Random.

## Notes

- How to start developing?
  - Should I depend mostly on HAR files?
    - I could get biased towards HAR files.
  - Should I start developing the DSL?
    - I could develop something really hard to replicate from HAR files.

- Browsers use multiple threads (6 maybe) to retrieve the response from each request.
