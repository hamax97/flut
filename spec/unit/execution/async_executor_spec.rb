# frozen_string_literal: true

require_relative "../../../lib/execution/async_executor"
require "async/rspec"

RSpec.describe Flut::AsyncExecutor do
  let(:async_executor) { Flut::AsyncExecutor.new }

  include_context Async::RSpec::Reactor

  describe "#async_context" do
    it "yields the given block inside an async context" do
      inside_async_context = false
      block = proc do
        inside_async_context = Flut::AsyncExecutor.inside_async_context?
      end

      async_executor.async_context(&block)

      expect(inside_async_context).to be true
    end

    it "waits for all async executions started inside it" do
      num_async_executions = 2
      executions_finished = Array.new(num_async_executions, false)
      task_idx = 0
      block = proc do
        num_async_executions.times do
          async_executor.execute do
            sleep 0.01
            executions_finished[task_idx] = true
            task_idx += 1
          end
        end
      end

      reactor.async do
        async_executor.async_context(&block)
        expect(executions_finished).to all be true
      end.wait
    end

    context "when inside another async context" do
      it "yields the block inside the already present async context" do
        child_context = nil
        block = proc do
          child_context = Async::Task.current
        end

        reactor.async do
          parent_context = Async::Task.current
          async_executor.async_context(&block)
          expect(child_context).to eq parent_context
        end.wait
      end
    end
  end

  describe "#execute" do
    it "yields the given block inside a new async execution" do
      new_context = nil
      block = proc do
        new_context = Async::Task.current
      end

      reactor.async do
        parent_context = Async::Task.current
        async_executor.execute(&block)
        expect(new_context).to_not eq parent_context
      end.wait
    end
  end
end
