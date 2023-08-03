# frozen_string_literal: true

require_relative "async_executor"
require_relative "../time/each_second_event"

module Flut
  class TPSCenteredExecutor
    attr_reader :current_tps

    # rubocop:disable Metrics/MethodLength
    def initialize(tps:, duration_sec:, async_executor: AsyncExecutor.new,
                   each_second_event: EachSecondEvent.new(duration_sec:), &testplan)
      @tps = tps
      @current_tps = 0
      @testplan = testplan
      @async_executor = async_executor
      @each_second_event = each_second_event
      @each_second_event.register(self, :execute)
      @each_second_event.register(self, :reset_tps_counter)
    end
    # rubocop:enable Metrics/MethodLength

    def start
      each_second_event.fire
    end

    def execute
      async_executor.async_context do
        missing_tps.times { async_execute(&testplan) }
      end
    end

    def reset_tps_counter
      @current_tps = 0
    end

    private

    attr_reader :async_executor, :each_second_event, :tps, :testplan

    def async_execute(&)
      async_executor.execute do
        yield
        @current_tps += 1
      end
    end

    def missing_tps
      [tps - current_tps, 0].max
    end
  end
end
