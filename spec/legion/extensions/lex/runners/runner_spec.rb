# frozen_string_literal: true

RSpec.describe Legion::Extensions::Lex::Runners::Runner do
  subject(:runner) { described_class }

  let(:extension_id) do
    Legion::Data::Model::Extension.insert(name: 'http', namespace: 'Legion::Extensions::Http', active: true)
  end

  describe '#create' do
    it 'inserts a new runner record' do
      result = runner.create(extension_id: extension_id, name: 'request')
      expect(result[:success]).to be true
      expect(result[:runner_id]).to be_a(Integer)
    end

    it 'updates an existing runner instead of duplicating' do
      runner.create(extension_id: extension_id, name: 'request', namespace: 'NS1')
      result = runner.create(extension_id: extension_id, name: 'request', namespace: 'NS2')
      expect(result[:success]).to be true
      expect(Legion::Data::Model::Runner.records.size).to eq 1
    end

    it 'defaults queue and uri to name' do
      runner.create(extension_id: extension_id, name: 'request')
      record = Legion::Data::Model::Runner.where(name: 'request').first
      expect(record.values[:queue]).to eq 'request'
      expect(record.values[:uri]).to eq 'request'
    end

    it 'stores namespace when provided' do
      runner.create(extension_id: extension_id, name: 'request', namespace: 'Legion::Extensions::Http::Runners::Request')
      record = Legion::Data::Model::Runner.where(name: 'request').first
      expect(record.values[:namespace]).to eq 'Legion::Extensions::Http::Runners::Request'
    end
  end

  describe '#update' do
    it 'updates specified columns' do
      create_result = runner.create(extension_id: extension_id, name: 'request', namespace: 'NS1')
      result = runner.update(runner_id: create_result[:runner_id], namespace: 'NS2')
      expect(result[:success]).to be true
      expect(result[:changed]).to be true
      expect(result[:updates]).to include(namespace: 'NS2')
    end

    it 'returns changed: false when no changes' do
      create_result = runner.create(extension_id: extension_id, name: 'request', namespace: 'NS1')
      result = runner.update(runner_id: create_result[:runner_id], namespace: 'NS1')
      expect(result[:success]).to be true
      expect(result[:changed]).to be false
    end

    it 'returns failure for missing runner' do
      result = runner.update(runner_id: 9999)
      expect(result[:success]).to be false
    end
  end

  describe '#get' do
    it 'retrieves by runner_id' do
      create_result = runner.create(extension_id: extension_id, name: 'request')
      result = runner.get(runner_id: create_result[:runner_id])
      expect(result[:success]).to be true
      expect(result[:values][:name]).to eq 'request'
    end

    it 'returns failure for missing runner' do
      result = runner.get(runner_id: 9999)
      expect(result[:success]).to be false
    end
  end

  describe '#delete' do
    it 'deletes the runner' do
      create_result = runner.create(extension_id: extension_id, name: 'request')
      result = runner.delete(runner_id: create_result[:runner_id])
      expect(result[:success]).to be true
    end

    it 'returns failure for missing runner' do
      result = runner.delete(runner_id: 9999)
      expect(result[:success]).to be false
    end
  end
end
