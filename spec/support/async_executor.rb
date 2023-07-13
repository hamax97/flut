# frozen_string_literal: true

require_relative "../../lib/execution/async_executor"
require "async/rspec"

module Flut
  module RSpec
    module AsyncExecutor
      ::RSpec.shared_context AsyncExecutor do
        let(:async_executor) { instance_spy(Flut::AsyncExecutor) }

        # What is a Reactor?
        # https://socketry.github.io/async/guides/getting-started/index.html
        include_context Async::RSpec::Reactor

        before do
          allow(async_executor).to receive(:execute).and_yield
          allow(async_executor).to receive(:async_context) do |&block|
            reactor.async { block.call }
          end
        end
      end
    end
  end
end
