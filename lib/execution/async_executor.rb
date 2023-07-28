# frozen_string_literal: true

require "async"
require "async/barrier"

module Flut
  class AsyncExecutor
    def self.inside_async_context?
      return true if Async::Task.current?

      false
    end

    def initialize
      @barrier = Async::Barrier.new
    end

    def async_context(&)
      # Sync will use the reactor that's already present, or create a new one.
      Sync do
        yield
      end

      barrier.wait
    end

    # Executes the given block inside an async task. It's intended to be used
    # inside async_context.
    def execute(&)
      raise "Not inside async context" unless AsyncExecutor.inside_async_context?

      barrier.async do
        yield
      end
    end

    private

    attr_reader :barrier
  end
end
