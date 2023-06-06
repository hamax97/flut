# frozen_string_literal: true

require_relative "../../lib/flut"

RSpec.describe Flut do
  describe ".execute" do
    let(:executor) { object_spy("Executor") }

    it "must receive a block to execute" do
      expect { Flut.execute(executor:) }.to raise_error(/nothing to execute/i)
    end

    it "calls an executor with the given block" do
      testplan = proc {}
      Flut.execute(executor:, &testplan)

      expect(executor).to have_received(:execute) do |&given_blk|
        expect(given_blk).to be(testplan)
      end
    end
  end
end
