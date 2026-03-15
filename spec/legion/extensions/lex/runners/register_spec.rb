# frozen_string_literal: true

RSpec.describe Legion::Extensions::Lex::Runners::Register do
  subject(:runner) { described_class }

  describe '#save' do
    let(:opts) do
      {
        request: {
          extension_name:  'http',
          extension_class: 'Legion::Extensions::Http',
          runner_class:    'Legion::Extensions::Http::Runners::Request',
          class_methods:   {
            get:  { args: [%i[keyreq url], %i[key timeout]] },
            post: { args: [%i[keyreq url], %i[keyreq body]] }
          }
        },
        health:  {
          extension_name:  'http',
          extension_class: 'Legion::Extensions::Http',
          runner_class:    'Legion::Extensions::Http::Runners::Health',
          class_methods:   {
            check: { args: [%i[keyreq endpoint]] }
          }
        }
      }
    end

    it 'creates extension, runners, and functions' do
      result = runner.save(opts: opts)
      expect(result[:success]).to be true
      expect(result[:extension_id]).to be_a(Integer)
      expect(result[:runners]).to eq 2
      expect(result[:functions]).to eq 3
    end

    it 'creates only one extension record' do
      runner.save(opts: opts)
      expect(Legion::Data::Model::Extension.records.size).to eq 1
      expect(Legion::Data::Model::Extension.records.first.values[:name]).to eq 'http'
    end

    it 'creates runner records for each runner' do
      runner.save(opts: opts)
      names = Legion::Data::Model::Runner.records.map { |r| r.values[:name] }
      expect(names).to contain_exactly('request', 'health')
    end

    it 'creates function records for each method' do
      runner.save(opts: opts)
      names = Legion::Data::Model::Function.records.map { |f| f.values[:name] }
      expect(names).to contain_exactly('get', 'post', 'check')
    end

    it 'returns failure for nil opts' do
      result = runner.save(opts: nil)
      expect(result[:success]).to be false
    end

    it 'returns failure for empty opts' do
      result = runner.save(opts: {})
      expect(result[:success]).to be false
    end

    it 'skips non-hash runner values' do
      result = runner.save(opts: { task_id: 123, request: opts[:request] })
      expect(result[:success]).to be true
      expect(result[:runners]).to eq 1
    end

    it 'handles runners with nil class_methods gracefully' do
      simple_opts = {
        request: {
          extension_name:  'http',
          extension_class: 'Legion::Extensions::Http',
          runner_class:    'Legion::Extensions::Http::Runners::Request',
          class_methods:   nil
        }
      }
      result = runner.save(opts: simple_opts)
      expect(result[:success]).to be true
      expect(result[:functions]).to eq 0
    end

    it 'is idempotent - re-registering updates instead of duplicating' do
      runner.save(opts: opts)
      runner.save(opts: opts)
      expect(Legion::Data::Model::Extension.records.size).to eq 1
    end
  end
end
