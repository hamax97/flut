# frozen_string_literal: true

require "async"

module Flut
  class TPSCenteredExecutor
    attr_reader :current_tps

    def initialize
      @current_tps = 0
      @executions = []
    end

    def execute(tps, &)
      missing_tps(tps).times do
        async_execute(&)
      end

      wait_executions
    end

    private

    attr_reader :executions

    def async_execute(&)
      executions << Async do
        yield
        @current_tps += 1
      end
    end

    def wait_executions
      # TODO: Create a test to make sure these tasks are deleted.
      executions.each(&:wait)
    end

    def missing_tps(tps)
      [tps - current_tps, 0].max
    end
  end
end
