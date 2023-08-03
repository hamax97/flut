# frozen_string_literal: true

require_relative "../../../lib/time/each_second_event"
require_relative "../../../lib/time/stepping_timer"
require_relative "../../../lib/execution/async_executor"

RSpec.describe Flut::EachSecondEvent do
  # rubocop:disable Metrics/MethodLength
  def stepping_timer(duration_sec)
    stepping_timer = instance_spy(Flut::SteppingTimer)
    allow(stepping_timer).to receive(:during).and_return stepping_timer
    allow(stepping_timer).to receive(:each_second) do |&block|
      duration_sec.times { block.call }
    end
    stepping_timer
  end
  # rubocop:enable Metrics/MethodLength

  def new_each_second_event(duration_sec)
    Flut::EachSecondEvent.new(duration_sec:, stepping_timer: stepping_timer(duration_sec))
  end

  describe "#register" do
    it "adds objects to the list of listeners" do
      duration_sec = 1
      each_second_event = new_each_second_event(duration_sec)
      listener = spy("SomeListener") # rubocop:disable RSpec/VerifiedDoubles
      other_listener = spy("SomeOtherListener") # rubocop:disable RSpec/VerifiedDoubles

      each_second_event.register(listener, :some_method)
      each_second_event.register(other_listener, :some_other_method)
      each_second_event.fire

      expect(listener).to have_received(:some_method)
      expect(other_listener).to have_received(:some_other_method)
    end
  end

  describe "#fire" do
    it "notifies listeners each second" do
      duration_sec = rand(2..5)
      each_second_event = new_each_second_event(duration_sec)

      listener = spy("SomeListener") # rubocop:disable RSpec/VerifiedDoubles
      each_second_event.register(listener, :some_method)
      each_second_event.fire

      expect(listener).to have_received(:some_method).exactly(duration_sec).times
    end

    it "notifies listeners inside an async context" do
      duration_sec = rand(2..5)
      each_second_event = new_each_second_event(duration_sec)

      listener = spy("SomeListener") # rubocop:disable RSpec/VerifiedDoubles
      inside_async_context = false
      allow(listener).to receive(:some_method) do
        inside_async_context = Flut::AsyncExecutor.inside_async_context?
      end

      each_second_event.register(listener, :some_method)
      each_second_event.fire

      expect(inside_async_context).to be true
    end
  end
end
