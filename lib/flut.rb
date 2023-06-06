# frozen_string_literal: true

module Flut
  def self.execute(executor:, &testplan)
    raise "Nothing to execute" if testplan.nil?

    executor.execute(&testplan)
  end
end
