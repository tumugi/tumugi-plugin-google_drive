# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "tumugi-plugin-google_drive"
  spec.version       = "0.4.0"
  spec.authors       = ["Kazuyuki Honda"]
  spec.email         = ["hakobera@gmail.com"]

  spec.summary       = "Tumugi plugin for Google Drive"
  spec.homepage      = "https://github.com/tumugi/tumugi-plugin-gcs"
  spec.license       = "Apache License Version 2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1'

  spec.add_runtime_dependency "tumugi", ">= 0.6.1"
  spec.add_runtime_dependency "google-api-client", "~> 0.9.3"
  spec.add_runtime_dependency "json", "~> 1.8.3" # json 2.0 does not work with JRuby + MultiJson

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit", "~> 3.1"
  spec.add_development_dependency "test-unit-rr"
  spec.add_development_dependency "coveralls"
end
