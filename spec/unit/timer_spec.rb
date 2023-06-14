# frozen_string_literal: true

require_relative "../../lib/timer"

RSpec.describe Flut::Timer do
  let(:timer) { Flut::Timer }

  describe ".during" do
    it "executes a block repeatedly during the given time" do
      duration_sec = 0.01

      start_time = timer.clocktime
      timer.during(duration_sec, &-> {})
      elapsed_time_sec = timer.clocktime - start_time

      expect(elapsed_time_sec).to be_within(0.01).of(duration_sec)
    end

    it "yields control to the given block" do
      expect { |block| timer.during(0.01, &block) }.to yield_control
    end

    it "raises error if no block given" do
      expect { timer.during(0.01) }.to raise_error(/nothing to execute/i)
    end
  end

  describe ".clocktime" do
    it "uses the Process.clock_gettime method" do
      # expect(Process)
      #   .to receive(:clock_gettime)
      #   .with(Process::CLOCK_MONOTONIC)
      #   .and_call_original
      allow(Process).to receive(:clock_gettime).and_call_original

      timer.clocktime

      expect(Process)
        .to have_received(:clock_gettime)
        .with(Process::CLOCK_MONOTONIC)

      # Timer.now should not be used to measure processing times:
      # https://blog.dnsimple.com/2018/03/elapsed-time-with-ruby-the-right-way/
    end
  end
end
