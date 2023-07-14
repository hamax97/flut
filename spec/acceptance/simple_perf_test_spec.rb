# frozen_string_literal: true

require_relative "../../lib/execution/tps_centered_orchestrator"
require_relative "../../lib/execution/tps_centered_executor"

# rubocop:disable Layout/IndentationWidth
module Flut
RSpec.describe "Simple performance test" do
  let(:target_tps_list) do
    [
      TargetTPS.new(tps: 20, duration_sec: 1),
      TargetTPS.new(tps: 100, duration_sec: 10),
      TargetTPS.new(tps: 20, duration_sec: 1)
    ]
  end

  it "runs at the desired tps rate" do
    executor = TPSCenteredExecutor.new
    orchestrator = TPSCenteredOrchestrator.new tps_centered_executor: executor

    # TODO: implement an event subscriber that executes callbacks each event.
    # TODO: subscribe to the each_second event and print info.
    # TODO: only counting TPS is not enough, I need to check second by second.

    tps_counter = 0
    orchestrator.execute(target_tps_list) do
      sleep rand(0.1..0.5) # some I/O operation.
      tps_counter += 1
    end

    expect(tps_counter).to eq 1040
  end
end
end
# rubocop:enable Layout/IndentationWidth
