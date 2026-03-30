# frozen_string_literal: true

require 'legion/extensions/transport'
require 'legion/transport/exchanges/extensions'

module Legion
  module Extensions
    module Lex
      module Transport
        extend Legion::Extensions::Transport

        def self.additional_e_to_q
          [
            {
              from:        Legion::Transport::Exchanges::Extensions,
              to:          'Register',
              routing_key: 'extension_manager.register.#'
            }
          ]
        end
      end
    end
  end
end
