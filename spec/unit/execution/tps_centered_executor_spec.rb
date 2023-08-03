# frozen_string_literal: true

require_relative "../../../lib/execution/tps_centered_executor"
require_relative "../../../lib/time/each_second_event"
require_relative "../../support/async_executor"

RSpec.describe Flut::TPSCenteredExecutor do
  include_context Flut::RSpec::AsyncExecutor

  it "counts the current number of tps" do
    testplan = -> {}
    executor = Flut::TPSCenteredExecutor.new(tps: 1, duration_sec: 1, &testplan)
    expect(executor).to respond_to :current_tps
  end

  it "initializes current_tps to zero" do
    testplan = -> {}
    executor = Flut::TPSCenteredExecutor.new(tps: 1, duration_sec: 1, &testplan)
    expect(executor.current_tps).to eq 0
  end

  describe "#start" do
    it "triggers the execution" do
      testplan = -> {}
      each_second_event = instance_spy(Flut::EachSecondEvent)
      executor = Flut::TPSCenteredExecutor.new(
        tps: 1, duration_sec: 1, each_second_event:, &testplan
      )

      executor.start

      expect(each_second_event).to have_received(:register).with(executor, :execute)
      expect(each_second_event).to have_received(:register).with(executor, :reset_tps_counter)
      expect(each_second_event).to have_received(:fire)
    end
  end

  describe "#execute" do
    it "sets the current tps to the desired tps" do
      testplan = -> {}
      tps = rand(2..5)
      executor = Flut::TPSCenteredExecutor.new(tps:, duration_sec: 1, &testplan)

      executor.execute

      expect(executor.current_tps).to eq tps
    end

    it "starts execution the given # of tps" do
      executions_count = 0
      testplan = -> { executions_count += 1 }
      tps = rand(2..5)
      executor = Flut::TPSCenteredExecutor.new(tps:, duration_sec: 1, &testplan)
      current_tps = executor.current_tps

      executor.execute
      executor.execute # tps already reached, no executions here.

      expected_yields = [tps - current_tps, 0].max
      expect(executions_count).to eq expected_yields
    end

    context "when the target tps is zero" do
      it "doesn't execute the block" do
        expect do |testplan|
          tps = 0
          executor = Flut::TPSCenteredExecutor.new(tps:, duration_sec: 1, &testplan)
          executor.execute
        end.to_not yield_control
      end
    end

    it "starts each execution inside an asynchronous context" do
      testplan = -> {}
      executor = Flut::TPSCenteredExecutor.new(tps: 2, duration_sec: 1, async_executor:, &testplan)

      executor.execute

      expect(async_executor).to have_received(:async_context).once
    end

    it "starts each execution asynchronously" do
      testplan = -> {}
      tps = rand(2..5)
      executor = Flut::TPSCenteredExecutor.new(tps:, duration_sec: 1, async_executor:, &testplan)

      executor.execute

      expect(async_executor).to have_received(:execute).exactly(tps).times
    end

    # TODO: add this feature in a future release.
    context "when target tps is between 0 and 1" do
      it "doesn't execute the block more than once per second"
      it "executes the given block once per the implied number of seconds"
    end
  end

  describe "#reset_tps_counter" do
    it "sets current_tps to zero" do
      testplan = -> {}
      tps = rand(2..5)
      executor = Flut::TPSCenteredExecutor.new(tps:, duration_sec: 1, &testplan)
      executor.execute
      expect(executor.current_tps).to eq tps

      executor.reset_tps_counter
      expect(executor.current_tps).to eq 0
    end
  end
end
