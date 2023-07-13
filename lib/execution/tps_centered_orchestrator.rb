# frozen_string_literal: true

require_relative "tps_centered_executor"
require_relative "async_executor"
require_relative "../time/stepping_timer"

module Flut
  class TPSCenteredOrchestrator
    def initialize(
      tps_centered_executor: TPSCenteredExecutor.new,
      stepping_timer: SteppingTimer.new,
      async_executor: AsyncExecutor.new
    )
      @tps_centered_executor = tps_centered_executor
      @stepping_timer = stepping_timer
      @async_executor = async_executor
    end

    def execute(target_tps_list, &)
      async_execute(target_tps_list, &)
    end

    private

    attr_reader :tps_centered_executor, :stepping_timer, :async_executor

    def async_execute(target_tps_list, &)
      async_executor.async_context do
        target_tps_list.each do |target_tps|
          start_executions(target_tps, &)
        end
      end
    end

    def start_executions(target_tps, &)
      stepping_timer.during(target_tps.duration_sec).each_second do
        execute_and_reset_tps(target_tps.tps, &)
      end
    end

    def execute_and_reset_tps(tps, &)
      async_executor.execute do
        tps_centered_executor.execute(tps, &)
        tps_centered_executor.reset_tps_counter
      end
    end
  end
end
