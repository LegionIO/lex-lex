# frozen_string_literal: true

require 'legion/extensions/lex'
require 'legion/extensions/lex/version'

RSpec.describe Legion::Extensions::Lex do
  it 'has a version number' do
    expect(Legion::Extensions::Lex::VERSION).not_to be nil
  end
end
