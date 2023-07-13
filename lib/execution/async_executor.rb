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

    def execute(&)
      barrier.async do
        yield
      end
    end

    private

    attr_reader :barrier
  end
end
