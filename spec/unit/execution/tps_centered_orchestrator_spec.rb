# frozen_string_literal: true

require_relative "../../../lib/execution/tps_centered_orchestrator"
require_relative "../../../lib/execution/tps_centered_executor"
require_relative "../../../lib/time/stepping_timer"
require "async"

# TODO: move this somewhere else.
TargetTPS = Struct.new(:tps, :duration_sec)

RSpec.describe Flut::TPSCenteredOrchestrator do
  let(:tps_centered_executor) { instance_spy(Flut::TPSCenteredExecutor) }
  let(:stepping_timer) { instance_spy(Flut::SteppingTimer) }
  let(:tps_centered_orchestrator) do
    Flut::TPSCenteredOrchestrator.new(tps_centered_executor:, stepping_timer:)
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
        testplan = -> {}
        tps_centered_orchestrator.execute(target_tps_list, &testplan)

        target_tps_list.each do |t|
          expect(stepping_timer).to have_received(:during).with(t.duration_sec)
        end

        expect(stepping_timer).to have_received(:each_second).exactly(target_tps_list.size).times
      end

      it "executes the given block with the specified target tps" do
        allow(stepping_timer).to receive(:each_second).and_yield

        testplan = -> {}
        tps_centered_orchestrator.execute(target_tps_list, &testplan)

        target_tps_list.each do |t|
          expect(tps_centered_executor)
            .to have_received(:execute)
            .with(t.tps) do |&given_block|
              expect(given_block).to eq(testplan)
            end
        end
      end

      it "executes the given block inside an async context" do
        allow(stepping_timer).to receive(:each_second).and_yield

        allow(tps_centered_executor).to receive(:execute) do
          expect(Async::Task.current?).not_to be_nil
        end

        testplan = -> {}
        tps_centered_orchestrator.execute(target_tps_list, &testplan)
      end

      it "waits for each execution of the given block to finish" do
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
