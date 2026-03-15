# frozen_string_literal: true

module Legion
  module Extensions
    module Lex
      module Runners
        module Runner
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def create(extension_id:, name:, active: true, **opts)
            existing = Legion::Data::Model::Runner.where(name: name.to_s, extension_id: extension_id).first
            return update(runner_id: existing.values[:id], name: name, active: active, **opts) if existing

            insert = {
              extension_id: extension_id,
              name:         name.to_s,
              active:       active,
              namespace:    opts[:namespace]
            }
            insert[:queue] = opts.fetch(:queue, name.to_s)
            insert[:uri] = opts.fetch(:uri, name.to_s)
            id = Legion::Data::Model::Runner.insert(insert)
            { success: true, runner_id: id }
          end

          def update(runner_id:, **opts)
            runner = Legion::Data::Model::Runner[runner_id]
            return { success: false, reason: 'runner not found' } if runner.nil?

            update = {}
            %i[name namespace active queue uri].each do |column|
              next unless opts.key?(column)
              next if runner.values[column] == opts[column]

              update[column] = opts[column]
            end

            return { success: true, changed: false, runner_id: runner_id } if update.empty?

            runner.update(update)
            { success: true, changed: true, updates: update, runner_id: runner_id }
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
            { success: true, runner_id: runner_id }
          end
        end
      end
    end
  end
end
