# frozen_string_literal: true

require_relative 'lex/version'
require_relative 'lex/runners/extension'
require_relative 'lex/runners/runner'
require_relative 'lex/runners/function'
require_relative 'lex/runners/register'
require_relative 'lex/runners/sync'
require_relative 'lex/actors/agent_watcher'

module Legion
  module Extensions
    module Lex
      extend Legion::Extensions::Core if Legion::Extensions.const_defined?(:Core, false)

      def self.data_required? # rubocop:disable Legion/Extension/DataRequiredWithoutMigrations
        true
      end
    end
  end
end
