# frozen_string_literal: true

require_relative "../../../lib/execution/async_executor"
require "async/rspec"

RSpec.describe Flut::AsyncExecutor do
  let(:async_executor) { Flut::AsyncExecutor.new }

  include_context Async::RSpec::Reactor

  describe "#async_context" do
    it "yields the given block inside an Async context" do
      inside_async_context = false
      block = proc do
        inside_async_context = Flut::AsyncExecutor.inside_async_context?
      end

      async_executor.async_context(&block)

      expect(inside_async_context).to be true
    end

    context "when inside another async context" do
      # By default, a top-level Async context will wait for all tasks started inside it.
      it "waits for all async tasks started inside it" do
        num_async_tasks = 2
        executions_finished = Array.new(num_async_tasks, false)
        task_idx = 0
        block = proc do
          num_async_tasks.times do
            Async do
              sleep 0.01
              executions_finished[task_idx] = true
              task_idx += 1
            end
          end
        end

        reactor.async do
          async_executor.async_context(&block)
          expect(executions_finished).to all be true
        end
      end
    end
  end

  describe "#execute" do
    it "yields the given block inside a new Async Task" do
      reactor.async do
        parent_context = Async::Task.current
        inside_different_context = false
        block = proc do
          new_context = Async::Task.current
          inside_different_context = parent_context != new_context
        end

        async_executor.execute(&block)
        expect(inside_different_context).to be true
      end
    end
  end
end
