# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'English'
require 'acts_as_removable/version'

Gem::Specification.new do |spec|
  spec.name          = 'acts_as_removable'
  spec.version       = ActsAsRemovable::VERSION
  spec.authors       = ['Florian Schwab', 'Erik-B. Ernst']
  spec.email         = ['florian.schwab@sic.software', 'erik.ernst@sic.software']
  spec.description   = 'Simplifies handling of pseudo removed records.'
  spec.summary       = 'Simplifies handling of pseudo removed records.'
  spec.homepage      = 'https://github.com/SICSoftwareGmbH/acts_as_removable'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.1.0'

  spec.add_dependency 'activerecord',  '>= 7.1', '< 8.1'
  spec.add_dependency 'activesupport', '>= 7.1', '< 8.1'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'sqlite3'
end
