# frozen_string_literal: true

RSpec.describe Legion::Extensions::Lex::Runners::Function do
  subject(:runner) { described_class }

  let(:extension_id) do
    Legion::Data::Model::Extension.insert(name: 'http', namespace: 'Legion::Extensions::Http', active: true)
  end

  let(:runner_id) do
    Legion::Data::Model::Runner.insert(extension_id: extension_id, name: 'request', namespace: 'NS', active: true)
  end

  describe '#create' do
    it 'inserts a new function record' do
      result = runner.create(runner_id: runner_id, name: 'get')
      expect(result[:success]).to be true
      expect(result[:function_id]).to be_a(Integer)
    end

    it 'updates an existing function instead of duplicating' do
      runner.create(runner_id: runner_id, name: 'get')
      result = runner.create(runner_id: runner_id, name: 'get', active: false)
      expect(result[:success]).to be true
      expect(Legion::Data::Model::Function.records.size).to eq 1
    end

    it 'stores formatted_args as JSON' do
      runner.create(runner_id: runner_id, name: 'get', formatted_args: { url: :keyreq })
      record = Legion::Data::Model::Function.where(name: 'get').first
      expect(record.values[:args]).to be_a(String)
    end

    it 'does not set args when formatted_args is absent' do
      runner.create(runner_id: runner_id, name: 'get')
      record = Legion::Data::Model::Function.where(name: 'get').first
      expect(record.values).not_to have_key(:args)
    end
  end

  describe '#update' do
    it 'updates active flag' do
      create_result = runner.create(runner_id: runner_id, name: 'get', active: true)
      result = runner.update(function_id: create_result[:function_id], active: false)
      expect(result[:success]).to be true
      expect(result[:changed]).to be true
    end

    it 'updates formatted_args' do
      create_result = runner.create(runner_id: runner_id, name: 'get')
      result = runner.update(function_id: create_result[:function_id], formatted_args: { url: :keyreq })
      expect(result[:success]).to be true
      expect(result[:changed]).to be true
    end

    it 'returns changed: false when no changes' do
      create_result = runner.create(runner_id: runner_id, name: 'get', active: true)
      result = runner.update(function_id: create_result[:function_id])
      expect(result[:success]).to be true
      expect(result[:changed]).to be false
    end

    it 'returns failure for missing function' do
      result = runner.update(function_id: 9999)
      expect(result[:success]).to be false
    end
  end

  describe '#get' do
    it 'retrieves by function_id' do
      create_result = runner.create(runner_id: runner_id, name: 'get')
      result = runner.get(function_id: create_result[:function_id])
      expect(result[:success]).to be true
      expect(result[:values][:name]).to eq 'get'
    end

    it 'returns failure for missing function' do
      result = runner.get(function_id: 9999)
      expect(result[:success]).to be false
    end
  end

  describe '#delete' do
    it 'deletes the function' do
      create_result = runner.create(runner_id: runner_id, name: 'get')
      result = runner.delete(function_id: create_result[:function_id])
      expect(result[:success]).to be true
    end

    it 'returns failure for missing function' do
      result = runner.delete(function_id: 9999)
      expect(result[:success]).to be false
    end
  end

  describe '#build_args' do
    it 'transforms parameter arrays into a hash' do
      raw_args = [%i[keyreq url], %i[key timeout], %i[keyrest opts]]
      result = runner.build_args(raw_args: raw_args)
      expect(result[:success]).to be true
      expect(result[:formatted_args]).to include(url: :keyreq, timeout: :key)
    end

    it 'excludes opts and options params' do
      raw_args = [%i[keyreq name], %i[keyrest opts], %i[keyrest options]]
      result = runner.build_args(raw_args: raw_args)
      expect(result[:formatted_args]).not_to have_key(:opts)
      expect(result[:formatted_args]).not_to have_key(:options)
    end

    it 'returns empty hash for empty args' do
      result = runner.build_args(raw_args: [])
      expect(result[:success]).to be true
      expect(result[:formatted_args]).to eq({})
    end
  end
end
