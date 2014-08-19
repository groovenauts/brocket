# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'magellan/build/version'

Gem::Specification.new do |spec|
  spec.name          = "magellan-build"
  spec.version       = Magellan::Build::VERSION
  spec.authors       = ["akima"]
  spec.email         = ["t-akima@groovenauts.jp"]
  spec.summary       = %q{supports to build Docker Container with VERSION}
  spec.description   = %q{supports to build Docker Container with VERSION}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
