# frozen_string_literal: true

module Legion::Extensions::Lex
  module Runners
    module Register
      include Legion::Extensions::Helpers::Lex

      def self.save(opts:, **_options)
        extension_id = nil
        extension = nil
        master_id = opts[:task_id]
        opts.each do |runner_name, opt|
          if extension_id.nil?
            extension_args = { namespace: opt[:extension_class], name: opt[:extension_name], parent_id: opts[:task_id], master_id: opts[:master_id] }
            extension = Legion::Runner.run(runner_class: 'Legion::Extensions::Lex::Runners::Extension',
                                           function: 'create',
                                           args: extension_args,
                                           parent_id: opts[:task_id],
                                           master_id: master_id)
            extension_id = extension[:result][:extension_id]
            @parent_id = extension[:task_id]
          end

          runner_args = { extension_id: extension_id, name: runner_name, namespace: opt[:runner_class], parent_id: @parent_id, master_id: opts[:task_id] }
          runner = Legion::Runner.run(runner_class: 'Legion::Extensions::Lex::Runners::Runner',
                                      function: 'create',
                                      args: runner_args,
                                      parent_id: @parent_id,
                                      master_id: master_id)

          runner_id = if runner[:result].key? :result
                        runner[:result][:result][:runner_id]
                      else
                        runner[:result][:runner_id]
                      end

          opt[:class_methods].each do |function, values|
            build_args_hash = { master_id: master_id, parent_id: runner[:task_id], raw_args: values[:args] }
            args = Legion::Runner.run(runner_class: 'Legion::Extensions::Lex::Runners::Function',
                                      function: 'build_args',
                                      args: build_args_hash,
                                      parent_id: runner[:task_id],
                                      master_id: master_id)

            function_args = { runner_id: runner_id, name: function, formatted_args: args[:result][:formatted_args], master_id: master_id, parent_id: runner[:task_id] }
            function = Legion::Runner.run(runner_class: 'Legion::Extensions::Lex::Runners::Function',
                                          function: 'create',
                                          args: function_args,
                                          parent_id: args[:task_id],
                                          master_id: master_id)
          end
        end
        { success: true }
      rescue StandardError => e
        Legion::Logging.fatal e.message
        Legion::Logging.fatal e.backtrace
        raise(e)
      end
    end
  end
end
