# frozen_string_literal: true

require_relative 'lib/legion/extensions/lex/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-lex'
  spec.version       = Legion::Extensions::Lex::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = ' Write a short summary, because RubyGems requires one.'
  spec.description   = ': Write a longer description or delete this line.'
  spec.homepage      = 'https://bitbucket.org/legion-io'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://bitbucket.org/legion-io'
  spec.metadata['changelog_uri'] = 'https://bitbucket.org/legion-io'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
end
