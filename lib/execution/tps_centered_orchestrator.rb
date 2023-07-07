# frozen_string_literal: true

require_relative "tps_centered_executor"
require_relative "../time/stepping_timer"
require "async"

module Flut
  class TPSCenteredOrchestrator
    def initialize(tps_centered_executor:, stepping_timer:)
      @tps_centered_executor = tps_centered_executor || TPSCenteredExecutor.new
      @stepping_timer = stepping_timer || SteppingTimer.new
    end

    def execute(target_tps, &)
      async_execute(target_tps, &)
    end

    private

    attr_reader :tps_centered_executor, :stepping_timer, :tps_counter

    def async_execute(target_tps_list, &)
      # Sync waits for its child tasks implicitly.
      Sync do
        target_tps_list.each do |target_tps|
          start_executions(target_tps, &)
        end
      end
    end

    def start_executions(target_tps, &)
      stepping_timer.during(target_tps.duration_sec).each_second do
        Async { tps_centered_executor.execute(target_tps.tps, &) }
      end
    end
  end
end
