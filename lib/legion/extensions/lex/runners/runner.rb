module Legion::Extensions::Lex # rubocop:disable Style/ClassAndModuleChildren
  module Runners
    module Runner
      include Legion::Extensions::Helpers::Lex

      def create(extension_id:, name:, active: 1, **opts)
        exist = Legion::Data::Model::Runner.where(name: name.to_s).where(extension_id: extension_id).first
        unless exist.nil?
          update_hash = { runner_id: exist.values[:id], name: name, active: active, **opts }
          return Legion::Runner.run(runner_class: 'Legion::Extensions::Lex::Runners::Runner',
                                    function:     'update',
                                    args:         update_hash,
                                    parent_id:    opts[:task_id],
                                    master_id:    opts[:master_id])
        end
        insert = { extension_id: extension_id, name: name.to_s, active: active, namespace: opts[:namespace] }
        insert[:queue] = opts.key?(:queue) ? opts[:queue] : name.to_s
        insert[:uri] = opts.key?(:uri) ? opts[:uri] : name.to_s
        { success: true, runner_id: Legion::Data::Model::Runner.insert(insert) }
      end

      def update(runner_id:, **opts)
        runner = Legion::Data::Model::Runner[runner_id]
        update = {}
        %i[name namespace active queue uri].each do |column|
          next unless opts.key? column
          next if runner.values[column] == opts[column]

          update[column] = opts[column]
        end

        { success: true, changed: false, runner_id: runner_id } if update.count.zero?
        runner.update(update)
        { success: true, changed: true, updates: update, runner_id: runner_id }
      end

      def get(runner_id:, **_opts)
        Legion::Data::Model::Runner[runner_id].values
      end

      def delete(runner_id:, **_opts)
        { runner_id: runner_id, result: Legion::Data::Model::Runner[runner_id].delete }
      end
    end
  end
end
