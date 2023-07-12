# frozen_string_literal: true

require_relative "../../../lib/execution/tps_centered_orchestrator"
require_relative "../../../lib/execution/tps_centered_executor"
require_relative "../../../lib/execution/async_executor"
require_relative "../../../lib/time/stepping_timer"

# TODO: move this somewhere else.
TargetTPS = Struct.new(:tps, :duration_sec)

RSpec.describe Flut::TPSCenteredOrchestrator do
  let(:tps_centered_executor) { instance_spy(Flut::TPSCenteredExecutor) }
  let(:stepping_timer) { instance_spy(Flut::SteppingTimer) }
  let(:async_executor) { instance_spy(Flut::AsyncExecutor) }
  let(:tps_centered_orchestrator) do
    Flut::TPSCenteredOrchestrator.new(tps_centered_executor:, stepping_timer:, async_executor:)
  end

  describe "#execute" do
    context "with each of the target tps given" do
      let(:target_tps_list) do
        [
          TargetTPS.new(tps: 1, duration_sec: 1),
          TargetTPS.new(tps: 2, duration_sec: 3),
          TargetTPS.new(tps: 4, duration_sec: 2)
        ]
      end

      it "loops over the given block once a second for the specified duration" do
        skip "why is this not working/?"
        testplan = -> {}
        tps_centered_orchestrator.execute(target_tps_list, &testplan)

        target_tps_list.each do |t|
          expect(stepping_timer).to have_received(:during).with(t.duration_sec)
        end

        expect(stepping_timer).to have_received(:each_second).exactly(target_tps_list.size).times
      end

      it "executes the given block with the specified target tps" do
        skip "why is this not working/?"
        allow(stepping_timer).to receive(:each_second).and_yield

        testplan = -> {}
        tps_centered_orchestrator.execute(target_tps_list, &testplan)

        target_tps_list.each do |t|
          expect(tps_centered_executor).to have_received(:execute).with(t.tps)
        end
      end

      # TODO: finish refactoring these specs, perhaps the last one could be deleted.

      it "executes the given block inside an async context" do
        skip "not finished yet"
        allow(stepping_timer).to receive(:each_second).and_yield
        allow(tps_centered_executor).to receive(:execute).and_yield

        inside_async_context = false
        testplan = proc do
          inside_async_context = Flut::AsyncExecutor.inside_async_context?
        end
        tps_centered_orchestrator.execute(target_tps_list, &testplan)

        expect(inside_async_context).to be true
        expect(async_executor).to have_received(:async_context)
      end

      it "waits for each execution of the given block to finish" do
        skip "not finished yet"
        allow(stepping_timer).to receive(:each_second).and_yield
        allow(tps_centered_executor).to receive(:execute).and_yield

        executions_finished = Array.new(target_tps_list.size, false)
        exec_idx = 0
        testplan = proc do
          sleep 0.01
          executions_finished[exec_idx] = true
          exec_idx += 1
        end

        tps_centered_orchestrator.execute(target_tps_list, &testplan)

        expect(executions_finished).to all be true
      end
    end
  end
end
