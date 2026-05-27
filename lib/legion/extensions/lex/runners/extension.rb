# frozen_string_literal: true

module Legion
  module Extensions
    module Lex
      module Runners
        module Extension
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def create(name:, namespace:, active: true, **opts)
            existing = find_cached_extension(name)
            return update(extension_id: existing.values[:id], namespace: namespace, active: active, **opts) if existing # rubocop:disable Legion/Extension/RunnerReturnHash

            insert = { name: name, namespace: namespace, active: active }
            insert[:exchange] = opts.fetch(:exchange, name)
            insert[:uri] = opts.fetch(:uri, name)
            id = Legion::Data::Model::Extension.insert(insert)
            reload_static_caches
            { success: true, extension_id: id }
          end

          def update(extension_id:, **opts)
            extension = Legion::Data::Model::Extension[extension_id]
            return { success: false, reason: 'extension not found' } if extension.nil?

            changes = {}
            %i[name namespace active exchange uri].each do |column|
              next unless opts.key?(column)
              next if extension.values[column] == opts[column]

              changes[column] = opts[column]
            end

            return { success: true, changed: false, extension_id: extension_id } if changes.empty?

            extension.update(changes)
            reload_static_caches
            { success: true, changed: true, updates: changes, extension_id: extension_id }
          end

          def get(extension_id: nil, name: nil, namespace: nil, **_opts)
            dataset = Legion::Data::Model::Extension
            dataset = dataset.where(id: extension_id) if extension_id
            dataset = dataset.where(name: name) if name
            dataset = dataset.where(namespace: namespace) if namespace
            record = dataset.first
            return { success: false, reason: 'not found' } if record.nil?

            { success: true, values: record.values }
          end

          def delete(extension_id:, **_opts)
            record = Legion::Data::Model::Extension[extension_id]
            return { success: false, reason: 'not found' } if record.nil?

            record.delete
            reload_static_caches
            { success: true, extension_id: extension_id }
          end

          private

          def find_cached_extension(name)
            model = Legion::Data::Model::Extension
            if model.respond_to?(:cache) && model.respond_to?(:all)
              model.all.find { |e| e.values[:name] == name }
            else
              model.where(name: name).first
            end
          end

          def reload_static_caches
            [Legion::Data::Model::Extension, Legion::Data::Model::Runner, Legion::Data::Model::Function].each do |m|
              m.load_cache if m.respond_to?(:load_cache)
            end
          end
        end
      end
    end
  end
end
