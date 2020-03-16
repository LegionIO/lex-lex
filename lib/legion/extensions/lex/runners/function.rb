# frozen_string_literal: true

module Legion::Extensions::Lex
  module Runners
    module Function
      include Legion::Extensions::Helpers::Lex

      def create(runner_id:, name:, active: 1, **opts)
        exist = Legion::Data::Model::Function.where(name: name.to_s).where(runner_id: runner_id).first
        unless exist.nil?
          log.debug "function: #{exist.values[:id]} already exists, updating it"
          update_hash = { function_id: exist.values[:id], name: name, active: active, **opts }
          return Legion::Runner.run(runner_class: 'Legion::Extensions::Lex::Runners::Function',
                                    function: 'update',
                                    args: update_hash,
                                    parent_id: opts[:task_id],
                                    master_id: opts[:master_id])
        end
        insert = { runner_id: runner_id, name: name.to_s, active: active }
        insert[:args] = Legion::JSON.dump(opts[:formatted_args]) if opts.key? :formatted_args

        { success: true, function_id: Legion::Data::Model::Function.insert(insert) }
      end

      def update(function_id:, **opts)
        function = Legion::Data::Model::Function[function_id]
        update = {}
        update[:active] = true unless function.values[:active]

        if opts.key? :formatted_args
          args = JSON.dump(opts[:formatted_args])
          update[:args] = args unless args == function.values[:args]
        end

        return { success: true, changed: false, function_id: function_id } if update.count.zero?

        function.update(update)
        { success: true, changed: true, updates: update, function_id: function_id }
      end

      def get(function_id:, **opts)
        { function_id: function_id, values: Legion::Data::Model::Function[function_id].values }
      end

      def delete(function_id:, **opts)
        { function_id: function_id, result: Legion::Data::Model::Function[function_id].delete }
      end

      def self.build_args(raw_args:, **opts)
        args = {}
        raw_args.each do |arg|
          args[arg[1]] = arg[0] unless %w[opts options].include? arg[1]
        end
        { success: true, formatted_args: args }
      end
    end
  end
end
