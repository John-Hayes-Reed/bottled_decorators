# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bottled_decorators/version'

Gem::Specification.new do |spec|
  spec.name          = "bottled_decorators"
  spec.version       = BottledDecorators::VERSION
  spec.authors       = ["John_Hayes-Reed"]
  spec.email         = ["john.hayes.reed@gmail.com"]

  spec.summary       = %q{The easiest way to make decorators, the way they are supposed to be.}
  spec.description   = %q{This gem provides a class to be the base for decorators and a generator to easily create them.}
  spec.homepage      = "https://github.com/John-Hayes-Reed/bottled_decorators"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "railties"
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
