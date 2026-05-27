# frozen_string_literal: true

module Legion
  module Extensions
    module Lex
      module Runners
        module Runner # rubocop:disable Legion/Extension/RunnerPluralModule
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def create(extension_id:, name:, active: true, **opts)
            existing = find_cached_runner(name, extension_id)
            return update(runner_id: existing.values[:id], name: name, active: active, **opts) if existing # rubocop:disable Legion/Extension/RunnerReturnHash

            insert = {
              extension_id: extension_id,
              name:         name.to_s,
              active:       active,
              namespace:    opts[:namespace]
            }
            insert[:queue] = opts.fetch(:queue, name.to_s)
            insert[:uri] = opts.fetch(:uri, name.to_s)
            id = Legion::Data::Model::Runner.insert(insert)
            reload_static_caches
            { success: true, runner_id: id }
          end

          def update(runner_id:, **opts)
            runner = Legion::Data::Model::Runner[runner_id]
            return { success: false, reason: 'runner not found' } if runner.nil?

            changes = {}
            %i[name namespace active queue uri].each do |column|
              next unless opts.key?(column)
              next if runner.values[column] == opts[column]

              changes[column] = opts[column]
            end

            return { success: true, changed: false, runner_id: runner_id } if changes.empty?

            runner.update(changes)
            reload_static_caches
            { success: true, changed: true, updates: changes, runner_id: runner_id }
          end

          def get(runner_id:, **_opts)
            record = Legion::Data::Model::Runner[runner_id]
            return { success: false, reason: 'not found' } if record.nil?

            { success: true, values: record.values }
          end

          def delete(runner_id:, **_opts)
            record = Legion::Data::Model::Runner[runner_id]
            return { success: false, reason: 'not found' } if record.nil?

            record.delete
            reload_static_caches
            { success: true, runner_id: runner_id }
          end

          private

          def find_cached_runner(name, extension_id)
            model = Legion::Data::Model::Runner
            if model.respond_to?(:cache) && model.respond_to?(:all)
              model.all.find { |r| r.values[:name] == name.to_s && r.values[:extension_id] == extension_id }
            else
              model.where(name: name.to_s, extension_id: extension_id).first
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
