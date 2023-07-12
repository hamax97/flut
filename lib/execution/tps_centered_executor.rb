# frozen_string_literal: true

module Flut
  class TPSCenteredExecutor
    attr_reader :current_tps

    def initialize(async_executor:)
      @current_tps = 0
      @async_executor = async_executor
    end

    def execute(tps, &)
      async_executor.async_context do
        missing_tps(tps).times do
          async_execute(&)
        end
      end
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
      [tps - current_tps, 0].max
    end
  end
end
