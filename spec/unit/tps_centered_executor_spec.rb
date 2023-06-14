# frozen_string_literal: true

require_relative "../../lib/tps_centered_executor"
require_relative "../../lib/timer"
require "benchmark"

TargetTPS = Struct.new(:tps, :duration_sec)

RSpec.describe Flut::TPSCenteredExecutor do
  describe "#execute" do
    let(:executor) { Flut::TPSCenteredExecutor.new }

    it "executes the given block during the given duration" do
      duration_sec = 0.2
      target_tps = [TargetTPS.new(tps: 1, duration_sec:)]
      elapsed_time_sec = Benchmark.measure { executor.execute(target_tps, &-> {}) }.total

      expect(elapsed_time_sec).to be_within(0.1).of(duration_sec)
    end

    it "executes the given block the given number of times per second"

    context "when target duration is zero" do
      it "doesn't execute the block" do
        target_tps = [TargetTPS.new(tps: 1, duration_sec: 0)]
        expect { |block| executor.execute(target_tps, &block) }.not_to yield_control
      end

      it "skips the target tps immediately"
    end

    context "when target tps is zero" do
      it "stays idle during the specified duration"
      it "doesn't execute the block"
    end
  end
end
