# frozen_string_literal: true

require_relative "tps_centered_executor"
require_relative "../time/stepping_timer"

module Flut
  class TPSCenteredOrchestrator
    attr_reader :tps_centered_executor, :stepping_timer

    def initialize(
      tps_centered_executor: TPSCenteredExecutor.new,
      stepping_timer: SteppingTimer.new
    )
      @tps_centered_executor = tps_centered_executor
      @stepping_timer = stepping_timer
    end

    def execute(target_tps, &)
      target_tps.each do |t|
        stepping_timer.during(t.duration_sec).each_second do
          tps_centered_executor.execute(tps: t.tps, &)
        end
      end
    end
  end
end
