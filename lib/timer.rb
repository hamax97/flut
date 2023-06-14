# frozen_string_literal: true

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
  end
end
