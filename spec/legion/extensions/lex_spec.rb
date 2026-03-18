# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Lex do
  describe '.data_required?' do
    it 'returns true as a class-level method so the framework respects it' do
      expect(described_class.data_required?).to be true
    end
  end
end
