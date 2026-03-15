# frozen_string_literal: true

RSpec.describe Legion::Extensions::Lex::Runners::Extension do
  subject(:runner) { described_class }

  describe '#create' do
    it 'inserts a new extension record' do
      result = runner.create(name: 'http', namespace: 'Legion::Extensions::Http')
      expect(result[:success]).to be true
      expect(result[:extension_id]).to be_a(Integer)
    end

    it 'updates an existing extension instead of duplicating' do
      runner.create(name: 'http', namespace: 'Legion::Extensions::Http')
      result = runner.create(name: 'http', namespace: 'Legion::Extensions::HttpV2')
      expect(result[:success]).to be true
      expect(Legion::Data::Model::Extension.records.size).to eq 1
    end

    it 'defaults exchange and uri to name' do
      runner.create(name: 'redis', namespace: 'Legion::Extensions::Redis')
      record = Legion::Data::Model::Extension.where(name: 'redis').first
      expect(record.values[:exchange]).to eq 'redis'
      expect(record.values[:uri]).to eq 'redis'
    end

    it 'accepts custom exchange and uri' do
      runner.create(name: 'redis', namespace: 'Legion::Extensions::Redis', exchange: 'custom_ex', uri: 'custom_uri')
      record = Legion::Data::Model::Extension.where(name: 'redis').first
      expect(record.values[:exchange]).to eq 'custom_ex'
      expect(record.values[:uri]).to eq 'custom_uri'
    end
  end

  describe '#update' do
    it 'updates specified columns' do
      create_result = runner.create(name: 'http', namespace: 'Legion::Extensions::Http')
      result = runner.update(extension_id: create_result[:extension_id], namespace: 'Legion::Extensions::HttpV2')
      expect(result[:success]).to be true
      expect(result[:changed]).to be true
      expect(result[:updates]).to include(namespace: 'Legion::Extensions::HttpV2')
    end

    it 'returns changed: false when no changes needed' do
      create_result = runner.create(name: 'http', namespace: 'Legion::Extensions::Http')
      result = runner.update(extension_id: create_result[:extension_id], namespace: 'Legion::Extensions::Http')
      expect(result[:success]).to be true
      expect(result[:changed]).to be false
    end

    it 'returns failure for missing extension' do
      result = runner.update(extension_id: 9999, namespace: 'foo')
      expect(result[:success]).to be false
    end
  end

  describe '#get' do
    it 'retrieves by extension_id' do
      create_result = runner.create(name: 'http', namespace: 'Legion::Extensions::Http')
      result = runner.get(extension_id: create_result[:extension_id])
      expect(result[:success]).to be true
      expect(result[:values][:name]).to eq 'http'
    end

    it 'retrieves by name' do
      runner.create(name: 'http', namespace: 'Legion::Extensions::Http')
      result = runner.get(name: 'http')
      expect(result[:success]).to be true
      expect(result[:values][:namespace]).to eq 'Legion::Extensions::Http'
    end

    it 'returns failure for missing record' do
      result = runner.get(name: 'nonexistent')
      expect(result[:success]).to be false
    end
  end

  describe '#delete' do
    it 'deletes the extension' do
      create_result = runner.create(name: 'http', namespace: 'Legion::Extensions::Http')
      result = runner.delete(extension_id: create_result[:extension_id])
      expect(result[:success]).to be true
    end

    it 'returns failure for missing extension' do
      result = runner.delete(extension_id: 9999)
      expect(result[:success]).to be false
    end
  end
end
