# frozen_string_literal: true

RSpec.describe Legion::Extensions::Lex::Runners::Sync do
  subject(:runner) { described_class }

  describe '#sync' do
    context 'when legion-data is not connected' do
      before do
        allow(Legion::Settings).to receive(:[]).with(:data).and_return({ connected: false })
      end

      it 'returns failure with reason' do
        result = runner.sync
        expect(result[:success]).to be false
        expect(result[:reason]).to eq 'legion-data not connected'
      end

      it 'does not touch the database' do
        runner.sync
        expect(Legion::Data::Model::Extension.records).to be_empty
      end
    end

    context 'when legion-data is connected' do
      let(:extensions_hash) do
        {
          'http'  => {
            extension_class: 'Legion::Extensions::Http',
            gem_name:        'lex-http',
            version:         '0.1.0'
          },
          'redis' => {
            extension_class: 'Legion::Extensions::Redis',
            gem_name:        'lex-redis',
            version:         '0.2.0'
          }
        }
      end

      before do
        allow(Legion::Settings).to receive(:[]).with(:data).and_return({ connected: true })
        allow(Legion::Extensions).to receive(:instance_variable_get).with(:@extensions).and_return(extensions_hash)
        allow(Legion::Extensions).to receive(:instance_variable_get).with(:@loaded_extensions).and_return(%w[http redis])
      end

      it 'creates missing extension records' do
        result = runner.sync
        expect(result[:success]).to be true
        expect(result[:created]).to eq 2
        expect(result[:synced]).to eq 2
      end

      it 'updates existing extension records when namespace differs' do
        Legion::Data::Model::Extension.insert(
          name: 'http', namespace: 'Legion::Extensions::OldHttp', active: true, exchange: 'http', uri: 'http'
        )
        result = runner.sync
        expect(result[:success]).to be true
        expect(result[:updated]).to eq 1
        expect(result[:created]).to eq 1
      end

      it 'does not update when namespace matches' do
        Legion::Data::Model::Extension.insert(
          name: 'http', namespace: 'Legion::Extensions::Http', active: true, exchange: 'http', uri: 'http'
        )
        result = runner.sync
        expect(result[:updated]).to eq 1
        record = Legion::Data::Model::Extension.where(name: 'http').first
        expect(record.values[:namespace]).to eq 'Legion::Extensions::Http'
      end

      it 'skips extensions not in the loaded list' do
        allow(Legion::Extensions).to receive(:instance_variable_get).with(:@loaded_extensions).and_return(%w[http])
        result = runner.sync
        expect(result[:synced]).to eq 1
        expect(result[:created]).to eq 1
      end

      it 'handles nil extensions hash gracefully' do
        allow(Legion::Extensions).to receive(:instance_variable_get).with(:@extensions).and_return(nil)
        allow(Legion::Extensions).to receive(:instance_variable_get).with(:@loaded_extensions).and_return([])
        result = runner.sync
        expect(result[:success]).to be true
        expect(result[:synced]).to eq 0
      end

      it 'skips loaded extensions with nil values' do
        allow(Legion::Extensions).to receive(:instance_variable_get).with(:@extensions).and_return({})
        allow(Legion::Extensions).to receive(:instance_variable_get).with(:@loaded_extensions).and_return(%w[http])
        result = runner.sync
        expect(result[:synced]).to eq 0
      end
    end
  end
end
