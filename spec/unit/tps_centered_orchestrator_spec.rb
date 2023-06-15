# frozen_string_literal: true

require_relative "../../lib/tps_centered_orchestrator"
require_relative "../../lib/tps_centered_executor"

TargetTPS = Struct.new(:tps, :duration_sec)

RSpec.describe Flut::TPSCenteredOrchestrator do
  describe ".execute" do
    it "executes each of the target tps given with the block given" do
      tps_centered_executor = instance_spy(Flut::TPSCenteredExecutor)

      orchestrator = Flut::TPSCenteredOrchestrator.new(tps_centered_executor:)
      target_tps = [
        TargetTPS.new(tps: 1, duration_sec: 1),
        TargetTPS.new(tps: 2, duration_sec: 3),
        TargetTPS.new(tps: 4, duration_sec: 2)
      ]
      testplan = -> {}
      orchestrator.execute(target_tps, &testplan)

      target_tps.each do |t|
        expect(tps_centered_executor)
          .to have_received(:execute)
          .with(tps: t.tps, duration_sec: t.duration_sec)
          .once do |&given_block|
            expect(given_block).to eq(testplan)
          end
      end
    end
  end
end
