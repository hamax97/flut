# frozen_string_literal: true

require_relative "./timer"

module Flut
  class TPSCenteredExecutor
    def execute(tps:, duration_sec:, &)
      Timer.during(duration_sec, &)
    end
  end
end
