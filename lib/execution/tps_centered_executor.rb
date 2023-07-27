# frozen_string_literal: true

require_relative "async_executor"

module Flut
  class TPSCenteredExecutor
    attr_reader :current_tps

    def initialize(async_executor: AsyncExecutor.new)
      @async_executor = async_executor
      @current_tps = 0
    end

    def execute(tps, &)
      async_executor.async_context do
        missing_tps(tps).times do
          async_execute(&)
        end
      end
    end

    def reset_tps_counter
      @current_tps = 0
    end

    private

    attr_reader :async_executor

    def async_execute(&)
      async_executor.execute do
        yield
        @current_tps += 1
      end
    end

    def missing_tps(tps)
      # TODO: look at how JMeter or k6 does this.
      [tps - current_tps, 0].max
    end
  end
end
