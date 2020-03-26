# frozen_string_literal: true

module Legion::Extensions::Lex # rubocop:disable Style/ClassAndModuleChildren
  module Runners
    module Extension
      include Legion::Extensions::Helpers::Lex

      def create(name:, namespace:, active: 1, **opts)
        exist = model.where(name: name).first
        unless exist.nil?
          update_hash = { extension_id: exist.values[:id], namespace: namespace, **opts }
          return Legion::Runner.run(runner_class: to_s,
                                    function:     'update',
                                    args:         update_hash,
                                    parent_id:    opts[:task_id],
                                    master_id:    opts[:master_id] || opts[:task_id])[:result]
        end

        insert = { name: name, namespace: namespace, active: active }
        insert[:exchange] = opts.key?(:exchange) ? opts[:exchange] : name
        insert[:uri] = opts.key?(:uri) ? opts[:uri] : name
        { success: true, extension_id: model.insert(insert) }
      end

      def update(extension_id:, **opts)
        extension = Legion::Data::Model::Extension[extension_id]
        update = {}
        %i[name namespace active exchange uri].each do |column|
          next unless opts.key? column
          next if extension.values[column] == opts[column]

          update[column] = opts[column]
        end

        { success: true, changed: false, extension_id: extension_id } if update.count.zero?
        extension.update(update)
        { success: true, changed: true, updates: update, extension_id: extension_id }
      end

      def get(**opts)
        extension = Legion::Data::Model::Extension
        extension.where(id: opts[:extension_id]) if opts.key? :extension_id
        extension.where(name: opts[:name]) if opts.key? :name
        extension.where(namespace: opts[:namespace]) if opts.key? :namespace
        { success: true, values: extension.first.values }
      end

      def delete(extension_id:, **_opts)
        Legion::Data::Model::Extension[extension_id].delete
        { success: true, extension_id: extension_id }
      end

      private

      def model
        Legion::Data::Model::Extension
      end
    end
  end
end
