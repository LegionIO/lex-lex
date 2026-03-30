# frozen_string_literal: true

module Legion
  module Extensions
    module Lex
      module Transport
        module Queues
          class Register < Legion::Transport::Queue
            def queue_name
              'lex.register'
            end
          end
        end
      end
    end
  end
end
