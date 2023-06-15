# frozen_string_literal: true

require_relative "../../lib/tps_centered_executor"
require_relative "../../lib/timer"
require "benchmark"

RSpec.describe Flut::TPSCenteredExecutor do
  describe "#execute" do
    let(:executor) { Flut::TPSCenteredExecutor.new }

    it "executes the given block during the given duration" do
      duration_sec = 0.2
      elapsed_time_sec = Benchmark.measure do
        executor.execute(tps: 1, duration_sec:, &-> {})
      end.total

      expect(elapsed_time_sec).to be_within(0.1).of(duration_sec)
    end

    it "executes the given block the given number of times per second" do
      expect { |block| executor.execute(tps: 20, duration_sec: 0.2, &block) }
        .to yield_control
        .at_least(:once)
        .at_most(4).times # 20 * 0.2 = 4
    end

    context "when target duration is zero" do
      it "doesn't execute the block" do
        expect { |block| executor.execute(tps: 1, duration_sec: 0, &block) }.not_to yield_control
      end
    end

    context "when target tps is zero" do
      it "stays idle during the specified duration"
      it "doesn't execute the block"
    end
  end
end
