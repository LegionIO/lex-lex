require 'legion/extensions/lex/version'

module Legion
  module Extensions
    module Lex
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end

    def data_required?
      true
    end
  end
end
