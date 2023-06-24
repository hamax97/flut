# frozen_string_literal: true

require_relative "../../../lib/execution/tps_centered_orchestrator"
require_relative "../../../lib/execution/tps_centered_executor"
require_relative "../../../lib/time/stepping_timer"

# TODO: move this somewhere else.
TargetTPS = Struct.new(:tps, :duration_sec)

RSpec.describe Flut::TPSCenteredOrchestrator do
  describe "#execute" do
    context "with each of the target tps given" do
      let(:tps_centered_executor) { instance_spy(Flut::TPSCenteredExecutor) }
      let(:stepping_timer) { instance_spy(Flut::SteppingTimer) }
      let(:tps_centered_orchestrator) do
        Flut::TPSCenteredOrchestrator.new(tps_centered_executor:, stepping_timer:)
      end
      let(:target_tps) do
        [
          TargetTPS.new(tps: 1, duration_sec: 1),
          TargetTPS.new(tps: 2, duration_sec: 3),
          TargetTPS.new(tps: 4, duration_sec: 2)
        ]
      end

      it "loops over the given block once a second for the specified duration" do
        testplan = -> {}
        tps_centered_orchestrator.execute(target_tps, &testplan)

        target_tps.each do |t|
          expect(stepping_timer).to have_received(:during).with(t.duration_sec)
        end

        expect(stepping_timer).to have_received(:each_second).exactly(target_tps.size).times
      end

      it "executes the given block with the specified target tps" do
        allow(stepping_timer).to receive(:each_second).and_yield

        testplan = -> {}
        tps_centered_orchestrator.execute(target_tps, &testplan)

        target_tps.each do |t|
          expect(tps_centered_executor)
            .to have_received(:execute)
            .with(tps: t.tps) do |&given_block|
              expect(given_block).to eq(testplan)
            end
        end
      end
    end
  end
end
