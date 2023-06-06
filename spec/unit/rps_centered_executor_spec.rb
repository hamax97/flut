# frozen_string_literal: true

require_relative "../../lib/rps_centered_executor"

TargetRPS = Struct.new(:rps, :duration)

RSpec.describe Flut::RPSCenteredExecutor do
  describe "#execute" do
    let(:rps_load_policy) { object_double("RPSLoadPolicy") }
    let(:executor) { Flut::RPSCenteredExecutor.new load_policy: rps_load_policy }

    context "when given only one target rps" do
      it "executes the given block at least once" do
        allow(rps_load_policy)
          .to receive(:target_rps)
          .and_return([TargetRPS.new(rps: 1, duration: 0)])

        expect { |block| executor.execute(&block) }.to yield_control.at_least(:once)
      end

      # If the spec takes too long, how about tagging it so that it won't be executed unless
      # specified.
      it "executes the given block during the given duration"
      it "stops execution of the given block when duration is over"
    end

    context "when given multiple target rps" do
      it "executes the given block at least once per target rps" do
        target_rps = [
          TargetRPS.new(rps: 1, duration: 0),
          TargetRPS.new(rps: 2, duration: 0),
          TargetRPS.new(rps: 1, duration: 0)
        ]
        allow(rps_load_policy).to receive(:target_rps).and_return(target_rps)

        expect { |block| executor.execute(&block) }
          .to yield_control.at_least(target_rps.size).times
      end
    end

    context "when no target rps given" do
      it "doesn't execute the given block" do
        allow(rps_load_policy).to receive(:target_rps).and_return([])

        expect { |block| executor.execute(&block) }.to_not yield_control
      end
    end
  end
end
