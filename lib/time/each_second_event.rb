# frozen_string_literal: true

require_relative "stepping_timer"
require_relative "../execution/async_executor"
require "observer"

module Flut
  class EachSecondEvent
    include Observable

    def initialize(duration_sec:, stepping_timer: SteppingTimer.new,
                   async_executor: AsyncExecutor.new)
      @duration_sec = duration_sec
      @stepping_timer = stepping_timer
      @async_executor = async_executor
    end

    def register(observer, method)
      add_observer(observer, method)
    end

    def fire
      async_executor.async_context do
        stepping_timer.during(duration_sec).each_second do
          async_executor.execute { notify }
        end
      end
    end

    private

    attr_reader :duration_sec, :stepping_timer, :async_executor

    def notify
      changed
      notify_observers
    end
  end
end
