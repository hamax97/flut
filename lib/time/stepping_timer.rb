# frozen_string_literal: true

require_relative "timer"
require "benchmark"

module Flut
  class SteppingTimer
    attr_reader :duration_sec, :timer

    def initialize(timer: Timer)
      @timer = timer
    end

    def during(duration_sec)
      @duration_sec = duration_sec
      self
    end

    def each_second(&)
      timer.during(duration_sec) do
        elapsed_time_sec = timer.measure(&)
        timer.sleep(1 - elapsed_time_sec) if elapsed_time_sec < 1
      end
    end
  end
end
