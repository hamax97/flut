# frozen_string_literal: true

require_relative "../../lib/timer"
require "benchmark"

RSpec.describe Flut::Timer do
  let(:timer) { Flut::Timer }

  def expect_execution_to_last(duration_sec)
    elapsed_time_sec = Benchmark.measure { yield }.total
    expect(elapsed_time_sec).to be_within(0.01).of(duration_sec)
  end

  describe ".during" do
    it "executes a block repeatedly during the given time" do
      duration_sec = 0.01
      expect_execution_to_last(duration_sec) { timer.during(duration_sec, &-> {}) }
    end

    it "executes the given block" do
      expect { |block| timer.during(0.01, &block) }.to yield_control
    end

    it "raises error if no block given" do
      expect { timer.during(0.01) }.to raise_error(/nothing to execute/i)
    end

    context "when duration is zero" do
      it "doesn't execute the given block" do
        expect { |block| timer.during(0, &block) }.not_to yield_control
      end

      it "returns immediately" do
        duration_sec = 0
        expect_execution_to_last(duration_sec) { timer.during(duration_sec, &-> {}) }
      end
    end
  end

  describe ".clocktime" do
    it "uses the Process.clock_gettime method with a monotonic clock" do
      allow(Process).to receive(:clock_gettime)

      timer.clocktime

      expect(Process)
        .to have_received(:clock_gettime)
        .with(Process::CLOCK_MONOTONIC)

      # Timer.now should not be used to measure processing times:
      # https://blog.dnsimple.com/2018/03/elapsed-time-with-ruby-the-right-way/
    end
  end
end
