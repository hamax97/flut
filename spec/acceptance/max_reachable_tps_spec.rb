# frozen_string_literal: true

require_relative "../../lib/execution/tps_centered_orchestrator"
require_relative "../../lib/execution/tps_centered_executor"
require_relative "../../lib/time/timer"
require "httpx"
require "json"

# rubocop:disable Layout/IndentationWidth
module Flut
RSpec.describe "2000 TPS performance test" do
  # let(:target_tps_list) { [ TargetTPS.new(tps:1, duration_sec: 1)] }
  let(:target_tps_list) do
    [
      TargetTPS.new(tps: 200, duration_sec: 1),
      TargetTPS.new(tps: 2000, duration_sec: 10),
      TargetTPS.new(tps: 200, duration_sec: 1)
    ]
  end
  let(:url) { "http://localhost:3001" }
  let(:http_client) { HTTPX }

  def total_duration
    target_tps_list.reduce(0) { |sum, t| t.duration_sec + sum }
  end

  def total_transactions
    target_tps_list.reduce(0) { |sum, t| (t.tps * t.duration_sec) + sum }
  end

  it "runs at the desired tps rate" do
    executor = TPSCenteredExecutor.new
    orchestrator = TPSCenteredOrchestrator.new tps_centered_executor: executor

    tps_counter = 0
    elapsed_time_sec = Timer.measure do
      orchestrator.execute(target_tps_list) do
        # Uncomment this to hit the web server.
        # testplan

        # TODO: with a delay of 1..2 seconds it's not able to reach 2000 TPS.
        sleep rand(1..2)
        tps_counter += 1
      end
    end

    # TODO: make it's reaching the desired TPS each second.

    expect(tps_counter).to eq total_transactions
    expect(elapsed_time_sec).to be_between(total_duration, total_duration + 0.1)
  end

  # If you want to use this, spin up the server:
  # 1. Clone source code: https://github.com/mwinteringham/restful-booker
  # 2. docker compose build
  # 3. docker compose up -d
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def testplan
    token = get_token
    expect(token).to_not be_nil

    think_time

    booking_id = booking
    expect(booking_id).to_not be_nil

    think_time

    status = update_booking(booking_id, token)
    expect(status).to be 200

    think_time

    status = delete_booking(booking_id, token)
    expect(status).to be 201
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def get_token # rubocop:disable Naming/AccessorMethodName
    headers = { "content-type" => "application/json" }
    body = { username: "admin", password: "password123" }
    response = http_client.post("#{url}/auth", headers:, json: body)
    response_obj = JSON.parse(response.body.to_s)
    response_obj["token"]
  end

  def booking
    headers = { "content-type" => "application/json", "accept" => "application/json" }
    response = http_client.post("#{url}/booking", headers:, json: booking_body)
    response_obj = JSON.parse(response.body.to_s)
    response_obj["bookingid"]
  end

  # rubocop:disable Metrics/MethodLength
  def booking_body
    {
      firstname: "Hamilton",
      lastname: "Tobon",
      totalprice: rand(50..200),
      depositpaid: true,
      bookingdates: {
        checkin: Date.today.next_day.to_s,
        checkout: (Date.today + 3).to_s
      },
      additionalneeds: "Quietness"
    }
  end
  # rubocop:enable Metrics/MethodLength

  def update_booking(booking_id, token)
    headers = { "content-type" => "application/json",
                "accept" => "application/json",
                "cookie" => "token=#{token}" }
    response = http_client.put("#{url}/booking/#{booking_id}", headers:, json: update_booking_body)
    response.status
  end

  def update_booking_body
    body = booking_body
    body[:bookingdates][:checkout] = (Date.today + 15).to_s
    body
  end

  def delete_booking(booking_id, token)
    headers = { "cookie" => "token=#{token}" }
    response = http_client.delete("#{url}/booking/#{booking_id}", headers:)
    response.status
  end

  def think_time
    rand(0.1..0.5)
  end
end
end
# rubocop:enable Layout/IndentationWidth
