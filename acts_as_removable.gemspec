# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_removable/version'

Gem::Specification.new do |spec|
  spec.name          = "acts_as_removable"
  spec.version       = ActsAsRemovable::VERSION
  spec.authors       = ["Florian Schwab"]
  spec.email         = ["florian.schwab@sic-software.com"]
  spec.description   = %q{Simplifies handling of pseudo removed records}
  spec.summary       = %q{Simplifies handling of pseudo removed records}
  spec.homepage      = "https://github.com/SICSoftwareGmbH/acts_as_removable"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 4.0.0"
  spec.add_dependency "activerecord", "~> 4.0.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3"
end
