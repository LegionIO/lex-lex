# frozen_string_literal: true

require_relative 'lex/version'
require_relative 'lex/runners/extension'
require_relative 'lex/runners/runner'
require_relative 'lex/runners/function'
require_relative 'lex/runners/register'
require_relative 'lex/runners/sync'
require_relative 'lex/actors/agent_watcher' if defined?(Legion::Extensions::Actors::Every)

module Legion
  module Extensions
    module Lex
      extend Legion::Extensions::Core if Legion::Extensions.const_defined?(:Core)

      def self.data_required?
        true
      end
    end
  end
end
