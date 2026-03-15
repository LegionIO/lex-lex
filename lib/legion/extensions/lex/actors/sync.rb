# frozen_string_literal: true

require 'legion/extensions/actors/once'

module Legion
  module Extensions
    module Lex
      module Actor
        class Sync < Legion::Extensions::Actors::Once
          def runner_class
            Legion::Extensions::Lex::Runners::Sync
          end

          def runner_function
            'sync'
          end

          def use_runner?
            false
          end

          def check_subtask?
            false
          end

          def generate_task?
            false
          end

          def enabled?
            return false unless defined?(Legion::Settings)

            Legion::Settings[:data][:connected] == true
          rescue StandardError
            false
          end

          def delay
            5.0
          end
        end
      end
    end
  end
end
