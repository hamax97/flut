# frozen_string_literal: true

require_relative "./timer"

module Flut
  class TPSCenteredExecutor
    def execute(target_tps)
      target_tps.each do |t|
        Timer.during(t.duration_sec, &-> {})
      end
    end
  end
end
