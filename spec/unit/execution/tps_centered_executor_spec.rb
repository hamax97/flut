# frozen_string_literal: true

require_relative "../../../lib/execution/tps_centered_executor"
require_relative "../../support/async_executor"

RSpec.describe Flut::TPSCenteredExecutor do
  include_context Flut::RSpec::AsyncExecutor

  let(:executor) { Flut::TPSCenteredExecutor.new async_executor: }

  it "counts the current number of tps" do
    expect(executor).to respond_to :current_tps
  end

  it "initializes current_tps to zero" do
    current_tps = executor.current_tps
    expect(current_tps).to eq 0
  end

  describe "#execute" do
    it "starts each execution inside an asynchronous context" do
      tps = 2
      testplan = proc do
        expect(Flut::AsyncExecutor.inside_async_context?).to be true
      end
      executor.execute(tps, &testplan)

      expect(async_executor).to have_received(:async_context).once
    end

    it "starts each execution asynchronously" do
      tps = 2
      executor.execute(tps, &-> {})
      expect(async_executor).to have_received(:execute).twice
    end

    it "sets the current tps to the desired tps" do
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

    # TODO: add this feature in a future release.
    context "when target tps is between 0 and 1" do
      it "doesn't execute the block more than once per second"
      it "executes the given block once per the implied number of seconds"
    end
  end

  describe "#reset_tps_counter" do
    it "sets current_tps to zero" do
      tps = rand(2..5)
      testplan = -> {}
      executor.execute(tps, &testplan)

      executor.reset_tps_counter
      expect(executor.current_tps).to eq 0
    end
  end
end
