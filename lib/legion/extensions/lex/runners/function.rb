# frozen_string_literal: true

module Legion
  module Extensions
    module Lex
      module Runners
        module Function
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          RESERVED_ARG_NAMES = %w[opts options].freeze

          def create(runner_id:, name:, active: true, **opts)
            existing = find_cached_function(name, runner_id)
            return update(function_id: existing.values[:id], name: name, active: active, **opts) if existing # rubocop:disable Legion/Extension/RunnerReturnHash

            insert = { runner_id: runner_id, name: name.to_s, active: active }
            insert[:args] = json_dump(opts[:formatted_args]) if opts.key?(:formatted_args)

            id = Legion::Data::Model::Function.insert(insert)
            reload_static_caches
            { success: true, function_id: id }
          end

          def update(function_id:, **opts)
            function = Legion::Data::Model::Function[function_id]
            return { success: false, reason: 'function not found' } if function.nil?

            changes = {}
            changes[:active] = opts[:active] if opts.key?(:active) && function.values[:active] != opts[:active]

            if opts.key?(:formatted_args)
              args = json_dump(opts[:formatted_args])
              changes[:args] = args unless args == function.values[:args]
            end

            return { success: true, changed: false, function_id: function_id } if changes.empty?

            function.update(changes)
            reload_static_caches
            { success: true, changed: true, updates: changes, function_id: function_id }
          end

          def get(function_id:, **_opts)
            record = Legion::Data::Model::Function[function_id]
            return { success: false, reason: 'not found' } if record.nil?

            { success: true, values: record.values }
          end

          def delete(function_id:, **_opts)
            record = Legion::Data::Model::Function[function_id]
            return { success: false, reason: 'not found' } if record.nil?

            record.delete
            reload_static_caches
            { success: true, function_id: function_id }
          end

          def build_args(raw_args:, **_opts)
            args = {}
            raw_args.each do |arg|
              args[arg[1]] = arg[0] unless RESERVED_ARG_NAMES.include?(arg[1].to_s)
            end
            { success: true, formatted_args: args }
          end

          private

          def find_cached_function(name, runner_id)
            model = Legion::Data::Model::Function
            if model.respond_to?(:cache) && model.respond_to?(:all)
              model.all.find { |f| f.values[:name] == name.to_s && f.values[:runner_id] == runner_id }
            else
              model.where(name: name.to_s, runner_id: runner_id).first
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
