# frozen_string_literal: true

require_relative 'lib/legion/extensions/lex/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-lex'
  spec.version       = Legion::Extensions::Lex::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'Lex::Lex manages Legion Extensions'
  spec.description   = 'Used by Legion to keep track of which LEXs are installed and available in the cluster'
  spec.homepage      = 'https://bitbucket.org/legion-io'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://bitbucket.org/legion-io/lex-lex'
  spec.metadata['changelog_uri'] = 'https://bitbucket.org/legion-io/lex-lex'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'legionio'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
end
