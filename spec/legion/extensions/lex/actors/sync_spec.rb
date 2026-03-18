# frozen_string_literal: true

unless defined?(Legion::Extensions::Actors::Once)
  module Legion
    module Extensions
      module Actors
        class Once; end # rubocop:disable Lint/EmptyClass
      end
    end
  end
end

# Stub the require so the actor file doesn't try to load the real gem
$LOADED_FEATURES << 'legion/extensions/actors/once' unless $LOADED_FEATURES.include?('legion/extensions/actors/once')

require 'legion/extensions/lex/actors/sync'

RSpec.describe Legion::Extensions::Lex::Actor::Sync do
  subject(:actor_class) { described_class }

  let(:instance) { actor_class.allocate }

  describe '#runner_class' do
    it 'returns the Sync runner class' do
      result = actor_class.instance_method(:runner_class).bind_call(instance)
      expect(result).to eq Legion::Extensions::Lex::Runners::Sync
    end
  end

  describe '#runner_function' do
    it 'returns sync' do
      result = actor_class.instance_method(:runner_function).bind_call(instance)
      expect(result).to eq 'sync'
    end
  end

  describe '#use_runner?' do
    it 'returns false' do
      result = actor_class.instance_method(:use_runner?).bind_call(instance)
      expect(result).to be false
    end
  end

  describe '#check_subtask?' do
    it 'returns false' do
      result = actor_class.instance_method(:check_subtask?).bind_call(instance)
      expect(result).to be false
    end
  end

  describe '#generate_task?' do
    it 'returns false' do
      result = actor_class.instance_method(:generate_task?).bind_call(instance)
      expect(result).to be false
    end
  end

  describe '#enabled?' do
    context 'when Legion::Settings is defined and data is connected' do
      before do
        allow(Legion::Settings).to receive(:[]).with(:data).and_return({ connected: true })
      end

      it 'returns true' do
        result = actor_class.instance_method(:enabled?).bind_call(instance)
        expect(result).to be true
      end
    end

    context 'when Legion::Settings is defined and data is not connected' do
      before do
        allow(Legion::Settings).to receive(:[]).with(:data).and_return({ connected: false })
      end

      it 'returns false' do
        result = actor_class.instance_method(:enabled?).bind_call(instance)
        expect(result).to be false
      end
    end

    context 'when Legion::Settings raises an error' do
      before do
        allow(Legion::Settings).to receive(:[]).with(:data).and_raise(StandardError, 'no settings')
      end

      it 'returns false' do
        result = actor_class.instance_method(:enabled?).bind_call(instance)
        expect(result).to be false
      end
    end
  end

  describe '#delay' do
    it 'returns 5.0' do
      result = actor_class.instance_method(:delay).bind_call(instance)
      expect(result).to eq 5.0
    end
  end
end
