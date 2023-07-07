# frozen_string_literal: true

require_relative "../../../lib/execution/tps_centered_executor"
require "async/rspec"

RSpec.describe Flut::TPSCenteredExecutor do
  let(:executor) { Flut::TPSCenteredExecutor.new }

  it "counts the current number of tps" do
    current_tps = executor.current_tps
    expect(current_tps).to eq 0
  end

  describe "#execute" do
    it "sets the current tps the desired tps" do
      tps = rand(2..5)
      executor.execute(tps, &-> {})
      expect(executor.current_tps).to eq tps
    end

    context "when current_tps is zero" do
      it "starts execution the given # of times per second" do
        tps = rand(2..5)
        expect { |testplan| executor.execute(tps, &testplan) }.to yield_control.exactly(tps).times
      end
    end

    context "when current_tps is > 1" do
      it "starts executing (target_tps - current_tps) # of times" do
        current_tps = rand(2..5)
        executor.execute(current_tps, &-> {})
        tps = rand(2..5)
        expected_yields = [tps - current_tps, 0].max

        expect { |testplan| executor.execute(tps, &testplan) }
          .to yield_control.exactly(expected_yields).times
      end
    end

    context "when the target tps is zero" do
      it "doesn't execute the block" do
        tps = 0
        expect { |testplan| executor.execute(tps, &testplan) }.to_not yield_control
      end
    end

    context "when inside an async context" do
      include_context Async::RSpec::Reactor

      it "starts a new async task per each execution" do
        reactor.async do
          parent_context = Async::Task.current
          tps = 2
          testplan = proc do
            new_context = Async::Task.current
            expect(new_context).to_not be parent_context
          end

          executor.execute(tps, &testplan)
        end
      end

      it "waits for all executions to finish" do
        tps = 2
        executions_finished = Array.new(tps, false)
        exec_idx = 0
        testplan = proc do
          sleep 0.01
          executions_finished[exec_idx] = true
          exec_idx += 1
        end

        executor.execute(tps, &testplan)
        expect(executions_finished).to all be true
      end
    end

    context "when an execution finishes" do
      it "will never be waited for again" do
        skip "don't know how to test yet"
        # BUG HERE! executions not deleted yet (use a queue?)
        # Next .wait will be fast, but the executions list has to be emptied.
        # How to test this?

        tps = 1
        testplan = -> { sleep 0.01 }
        executor.execute(tps, &testplan)

        # then expect next execution to be quick (but this won't work)
        executor.execute(tps, &-> {})
      end
    end

    # TODO: add this feature in a future release.
    context "when target tps is between 0 and 1" do
      it "doesn't execute the block more than once per second"
      it "executes the given block once per the implied number of seconds"
    end
  end

  describe "#reset_tps_counter" do
    it "sets current_tps to zero"
  end
end
