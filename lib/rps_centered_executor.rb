# frozen_string_literal: true

module Flut
  class RPSCenteredExecutor
    attr_reader :load_policy

    def initialize(load_policy:)
      @load_policy = load_policy
    end

    def execute
      load_policy.target_rps.each do
        yield
      end
    end
  end
end
