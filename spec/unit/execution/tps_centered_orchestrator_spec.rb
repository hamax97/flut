# frozen_string_literal: true

require_relative "../../../lib/execution/tps_centered_orchestrator"
require_relative "../../../lib/execution/tps_centered_executor"
require_relative "../../../lib/time/stepping_timer"
require_relative "../../support/async_executor"

RSpec.describe Flut::TPSCenteredOrchestrator do
  include_context Flut::RSpec::AsyncExecutor

  let(:tps_centered_executor) { instance_spy(Flut::TPSCenteredExecutor) }
  let(:stepping_timer) { instance_spy(Flut::SteppingTimer) }
  let(:tps_centered_orchestrator) do
    Flut::TPSCenteredOrchestrator.new(tps_centered_executor:, stepping_timer:, async_executor:)
  end

  before do
    allow(tps_centered_executor).to receive(:execute).and_yield
    allow(stepping_timer).to receive(:during).and_return stepping_timer
    allow(stepping_timer).to receive(:each_second).and_yield
  end

  describe "#execute" do
    let(:target_tps_list) do
      [
        Flut::TargetTPS.new(tps: 1, duration_sec: 1),
        Flut::TargetTPS.new(tps: 2, duration_sec: 3),
        Flut::TargetTPS.new(tps: 4, duration_sec: 2)
      ]
    end

    context "with each of the target tps given" do
      it "loops over the given block once a second for the specified duration" do
        testplan = -> {}
        tps_centered_orchestrator.execute(target_tps_list, &testplan)

        target_tps_list.each do |t|
          expect(stepping_timer).to have_received(:during).with(t.duration_sec)
        end

        expect(stepping_timer).to have_received(:each_second).exactly(target_tps_list.size).times
      end

      it "executes the given block with the specified target tps" do
        testplan = -> {}
        tps_centered_orchestrator.execute(target_tps_list, &testplan)

        target_tps_list.each do |t|
          expect(tps_centered_executor).to have_received(:execute).with(t.tps)
        end
      end
    end

    context "when an execution finishes" do
      it "resets the current tps to zero" do
        testplan = -> {}
        tps_centered_orchestrator.execute(target_tps_list, &testplan)

        expect(tps_centered_executor)
          .to have_received(:reset_tps_counter)
          .exactly(target_tps_list.size)
          .times
      end
    end

    it "executes the given block inside an async context" do
      inside_async_context = false
      testplan = proc do
        inside_async_context = Flut::AsyncExecutor.inside_async_context?
      end
      tps_centered_orchestrator.execute(target_tps_list, &testplan)

      expect(inside_async_context).to be true
      expect(async_executor).to have_received(:async_context).once
    end

    it "starts each execution asynchronously" do
      testplan = -> {}
      tps_centered_orchestrator.execute(target_tps_list, &testplan)

      expect(async_executor).to have_received(:execute).at_least(target_tps_list.size).times
    end
  end
end
