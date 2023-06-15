# frozen_string_literal: true

module Flut
  class TPSCenteredOrchestrator
    attr_reader :executor

    def initialize(tps_centered_executor: TPSCenteredExecutor.new)
      @executor = tps_centered_executor
    end

    def execute(target_tps, &)
      target_tps.each do |t|
        executor.execute(tps: t.tps, duration_sec: t.duration_sec, &)
      end
    end
  end
end
