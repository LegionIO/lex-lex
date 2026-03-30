# frozen_string_literal: true

module Legion
  module Extensions
    module Lex
      module Actor
        class AgentWatcher < Legion::Extensions::Actors::Every # rubocop:disable Legion/Extension/EveryActorRequiresTime
          def runner_class
            self.class
          end

          def time = 30
          def run_now? = false
          def use_runner? = false
          def check_subtask? = false
          def generate_task? = false

          def action(**_opts)
            current = Legion::Extensions.instance_variable_get(:@load_yaml_agents) || []
            reloaded = 0

            current.each do |agent|
              path = agent[:_source_path]
              next unless path && File.exist?(path)
              next unless File.mtime(path) > agent[:_source_mtime]

              reloaded += 1
            end

            if reloaded.positive?
              Legion::Extensions.instance_variable_set(:@load_yaml_agents, nil)
              Legion::Extensions.load_yaml_agents
            end

            { reloaded: reloaded }
          end
        end
      end
    end
  end
end
