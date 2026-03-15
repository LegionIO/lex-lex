# frozen_string_literal: true

module Legion
  module Extensions
    module Lex
      module Runners
        module Register
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def save(opts:, **_options)
            return { success: false, reason: 'no opts provided' } if opts.nil? || opts.empty?

            extension_id = nil
            runners_created = 0
            functions_created = 0

            opts.each do |runner_name, runner_opts|
              next unless runner_opts.is_a?(Hash)

              if extension_id.nil?
                ext_result = Extension.create(
                  name:      runner_opts[:extension_name],
                  namespace: runner_opts[:extension_class].to_s
                )
                extension_id = ext_result[:extension_id]
              end

              runner_result = Runner.create(
                extension_id: extension_id,
                name:         runner_name.to_s,
                namespace:    runner_opts[:runner_class].to_s
              )
              runner_id = runner_result[:runner_id]
              runners_created += 1

              next unless runner_opts[:class_methods].is_a?(Hash)

              runner_opts[:class_methods].each do |func_name, func_opts|
                formatted = (Function.build_args(raw_args: func_opts[:args])[:formatted_args] if func_opts.is_a?(Hash) && func_opts[:args])

                Function.create(
                  runner_id:      runner_id,
                  name:           func_name.to_s,
                  formatted_args: formatted
                )
                functions_created += 1
              end
            end

            { success: true, extension_id: extension_id, runners: runners_created, functions: functions_created }
          rescue StandardError => e
            { success: false, error: e.message }
          end
        end
      end
    end
  end
end
