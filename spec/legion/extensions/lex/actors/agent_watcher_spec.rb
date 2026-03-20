# frozen_string_literal: true

require 'spec_helper'

unless defined?(Legion::Extensions::Actors::Every)
  module Legion
    module Extensions
      module Actors
        class Every
          def initialize(**_opts); end

          def enabled? = true

          def time = 30

          def run_now? = false

          def use_runner? = false
        end
      end
    end
  end
  $LOADED_FEATURES << 'legion/extensions/actors/every.rb'
end

require_relative '../../../../../lib/legion/extensions/lex/actors/agent_watcher'

RSpec.describe Legion::Extensions::Lex::Actor::AgentWatcher do
  subject(:actor) { described_class.new }

  describe '#time' do
    it 'returns 30 seconds' do
      expect(actor.time).to eq(30)
    end
  end

  describe '#run_now?' do
    it 'returns false' do
      expect(actor.run_now?).to be false
    end
  end

  describe '#use_runner?' do
    it 'returns false' do
      expect(actor.use_runner?).to be false
    end
  end

  describe '#action' do
    before do
      stub_const('Legion::Extensions', Module.new do
        def self.instance_variable_get(key)
          key == :@load_yaml_agents ? [{ name: 'a', _source_path: '/tmp/a.yaml', _source_mtime: Time.now - 100 }] : nil
        end

        def self.instance_variable_set(_key, _val); end

        def self.load_yaml_agents
          []
        end
      end)
    end

    it 'returns a hash with reloaded count' do
      result = actor.action
      expect(result).to be_a(Hash)
      expect(result).to have_key(:reloaded)
    end
  end
end
