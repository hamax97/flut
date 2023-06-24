# frozen_string_literal: true

require_relative "../time/timer"
require "async"

module Flut
  class TPSCenteredExecutor
    def initialize(timer: Timer)
      @timer = timer
    end

    def execute(tps:, &)
      tps.times do
        # Async { yield }
        yield
      end
      # if tps.zero?
      #   stay_idle duration_sec
      # else
      #   execute_per_second(tps:, duration_sec:, &)
      # end
    end

    private

    attr_reader :timer

    def stay_idle(duration_sec)
      sleep duration_sec
    end

    def execute_per_second(tps:, duration_sec:)
      sleep_time_sec = 1.to_f / tps
      timer.during(duration_sec) do
        yield
        sleep sleep_time_sec
      end
    end
  end
end
