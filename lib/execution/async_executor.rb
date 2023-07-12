# frozen_string_literal: true

require "async"

module Flut
  class AsyncExecutor
    def self.inside_async_context?
      return true if Async::Task.current?

      false
    end

    def async_context(&)
      # Sync waits for its child tasks implicitly. It's faster than Async.wait.
      Sync do
        yield
      end
    end

    def execute(&)
      Async do
        yield
      end
    end
  end
end
