# frozen_string_literal: true

require_relative "../../lib/execution/tps_centered_executor"

RSpec.describe Flut::TPSCenteredExecutor do
  describe "#execute" do
    it "counts the current number of tps"
    it "returns immediately after starting the execution of the given block"
    context "when the current tps is zero"
    context "when the current tps is between 1 and the desired tps"
    context "when the current tps is the desired tps"

    let(:executor) { Flut::TPSCenteredExecutor.new }

    # TODO: Find a way to mock duration. expect for timer.during instead of using benchmark.
    # TODO: Find a way to mock executions per second so that you don't have to wait.
    #       Maybe mock sleep (that would be awful) ??

    it "loops over the given block during the given duration" do
      skip "not ready yet"

      duration_sec = 1
      executor.execute(tps: 1, duration_sec:, &-> {})
      expect(timer).to have_received(:during).with duration_sec
    end

    it "executes the given block the given number of times per second" do
      skip "not ready yet"
      tps = 20
      duration_sec = 0.1
      expect { |block| executor.execute(tps:, duration_sec:, &block) }
        .to yield_control
        .at_least(:once)
        .at_most(tps * duration_sec).times
    end

    context "when the given block lasts for random amounts of time" do
      it "executes the block the given number of times per second"
    end

    context "when target tps is zero" do
      it "stays idle during the specified duration" do
        skip "not ready yet"
        duration_sec = 0.05
        expect_execution_to_take(duration_sec) do
          executor.execute(tps: 0, duration_sec:, &-> {})
        end
      end

      it "doesn't execute the block" do
        skip "not ready yet"
        expect { |block| executor.execute(tps: 0, duration_sec: 0.05, &block) }.not_to yield_control
      end
    end

    context "when target tps is between 0 and 1" do
      it "doesn't execute the block more than once per second"
      it "executes the given block once per the implied number of seconds"
    end
  end
end
