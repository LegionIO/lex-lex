# frozen_string_literal: true

require 'bundler/setup'

# Stub Legion modules before requiring the extension
module Legion
  module Extensions
    module Helpers
      module Core; end

      module Logger
        def log
          @log ||= NullLogger.new
        end
      end

      module Lex
        include Legion::Extensions::Helpers::Core
        include Legion::Extensions::Helpers::Logger

        def self.included(base)
          base.extend base if base.instance_of?(Module)
        end
      end
    end

    module Core; end

    def self.const_defined?(_name)
      false
    end

    def self.instance_variable_get(_name)
      nil
    end
  end

  module Settings
    def self.[](_key)
      { connected: false }
    end
  end

  module Logging
    def self.info(*); end
    def self.debug(*); end
    def self.warn(*); end
    def self.error(*); end
  end

  module JSON
    def self.dump(obj)
      require 'json'
      ::JSON.dump(obj)
    end

    def self.load(str)
      require 'json'
      ::JSON.parse(str, symbolize_names: true)
    end
  end
end

# Null logger for specs
class NullLogger
  def debug(*); end
  def info(*); end
  def warn(*); end
  def error(*); end
end

# Stub Sequel models
module Legion
  module Data
    module Model
      class Extension
        class << self
          attr_accessor :records

          def reset!
            @records = []
            @next_id = 0
          end

          def insert(hash)
            @next_id = (@next_id || 0) + 1
            record = new(@next_id, hash)
            (@records ||= []) << record
            @next_id
          end

          def where(**conditions)
            DatasetStub.new((@records || []).select do |r|
              conditions.all? { |k, v| r.values[k] == v }
            end)
          end

          def [](id_or_conditions)
            if id_or_conditions.is_a?(Hash)
              where(**id_or_conditions).first
            else
              (@records || []).find { |r| r.values[:id] == id_or_conditions }
            end
          end

          def order(_col)
            DatasetStub.new(@records || [])
          end

          def first
            (@records || []).first
          end
        end

        attr_reader :values

        def initialize(id, hash)
          @values = hash.merge(id: id)
        end

        def update(hash)
          @values.merge!(hash)
        end

        def delete
          self.class.records&.delete(self)
          1
        end
      end

      class Runner < Extension
        @records = []
        @next_id = 0
      end

      class Function < Extension
        @records = []
        @next_id = 0
      end
    end
  end
end

# Dataset stub for .where chaining
class DatasetStub
  def initialize(records)
    @records = records
  end

  def first
    @records.first
  end

  def where(**conditions)
    filtered = @records.select do |r|
      conditions.all? { |k, v| r.values[k] == v }
    end
    DatasetStub.new(filtered)
  end
end

require 'legion/extensions/lex'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.before do
    Legion::Data::Model::Extension.reset!
    Legion::Data::Model::Runner.reset!
    Legion::Data::Model::Function.reset!
  end
end
