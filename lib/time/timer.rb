# frozen_string_literal: true

require "benchmark"

module Flut
  module Timer
    def self.clocktime
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def self.during(duration_sec)
      raise "Nothing to execute" unless block_given?

      start_time = clocktime
      yield while (clocktime - start_time) < duration_sec
    end

    def self.sleep(time_sec)
      Kernel.sleep time_sec
    end

    def self.measure(&)
      Benchmark.measure(&).total
    end
  end
end
