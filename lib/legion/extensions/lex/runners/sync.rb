# frozen_string_literal: true

module Legion
  module Extensions
    module Lex
      module Runners
        module Sync
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def sync(**_opts)
            return { success: false, reason: 'legion-data not connected' } unless Legion::Settings[:data][:connected]

            extensions = Legion::Extensions.instance_variable_get(:@extensions) || {}
            loaded = Legion::Extensions.instance_variable_get(:@loaded_extensions) || []

            synced = 0
            created = 0
            updated = 0

            loaded.each do |ext_name|
              values = extensions[ext_name]
              next if values.nil?

              existing = Legion::Data::Model::Extension.where(name: ext_name).first
              if existing.nil?
                Legion::Data::Model::Extension.insert(
                  name:      ext_name,
                  namespace: values[:extension_class].to_s,
                  active:    true,
                  exchange:  ext_name,
                  uri:       ext_name
                )
                created += 1
              else
                ns = values[:extension_class].to_s
                if existing.values[:namespace] != ns
                  existing.update(namespace: ns)
                  updated += 1
                end
              end
              synced += 1
            end

            { success: true, synced: synced, created: created, updated: updated }
          rescue StandardError => e
            { success: false, error: e.message }
          end
        end
      end
    end
  end
end
