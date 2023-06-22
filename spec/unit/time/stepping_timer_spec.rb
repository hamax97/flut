# frozen_string_literal: true

require_relative "../../../lib/time/stepping_timer"
require_relative "../../../lib/time/timer"

RSpec.describe Flut::SteppingTimer do
  let(:timer) { object_spy(Flut::Timer) }
  let(:stepping_timer) { Flut::SteppingTimer.new(timer:) }

  before do
    stepping_timer.during(1)
  end

  describe "#during" do
    it "sets the duration (in seconds) of this timer" do
      duration_sec = rand(2..5)
      stepping_timer.during(duration_sec)
      expect(stepping_timer.duration_sec).to eq duration_sec
    end

    it "returns this timer for further chain messages" do
      same_timer = stepping_timer.during(1)
      expect(same_timer).to be stepping_timer
    end
  end

  describe "#each_second" do
    before do
      allow(timer).to receive(:during) do |duration_sec, &block|
        duration_sec.times { block.call }
      end

      allow(timer).to receive(:measure).and_yield.and_return 0.01
    end

    context "with the specified duration" do
      let(:duration_sec) { rand(2..5) }

      it "loops over the block" do
        stepping_timer.during(duration_sec).each_second(&-> {})
        expect(timer).to have_received(:during).once.with(duration_sec)
      end

      it "executes the given block once per each second" do
        expect { |block| stepping_timer.during(duration_sec).each_second(&block) }
          .to yield_control
          .exactly(duration_sec)
          .times
      end
    end

    it "measures elapsed time properly" do
      block_to_measure = -> {}
      stepping_timer.during(1).each_second(&block_to_measure)
      expect(timer).to have_received(:measure) do |&given_block|
        expect(given_block).to eq(block_to_measure)
      end
    end

    context "when the given block takes less than a second to execute" do
      it "sleeps the remaining time to achieve one second" do
        block_execution_time_sec = 0.01
        allow(timer).to receive(:measure).and_return block_execution_time_sec

        stepping_timer.during(1).each_second(&-> {})

        expect(timer)
          .to have_received(:sleep)
          .with a_value_within(0.01)
          .of(1 - block_execution_time_sec)
      end
    end

    context "when the given block takes more than a second to execute" do
      before do
        allow(timer).to receive(:measure).and_yield.and_return 1
      end

      it "executes the block" do
        expect { |block| stepping_timer.during(1).each_second(&block) }.to yield_control
      end

      it "doesn't sleep" do
        stepping_timer.during(1).each_second(&-> {})
        expect(timer).not_to have_received(:sleep)
      end

      it "logs a debug message indicating the delay"
    end
  end
end
