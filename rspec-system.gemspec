# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  # Metadata
  s.name        = "rspec-system"
  s.version     = "0.0.2"
  s.authors     = ["Ken Barber"]
  s.email       = ["ken@bob.sh"]
  s.homepage    = "https://github.com/kbarber/rspec-system"
  s.summary     = "System testing with rspec"

  # Manifest
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*_spec.rb`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Dependencies
  s.required_ruby_version = '>= 1.9.3'
  s.add_runtime_dependency "rspec"
  s.add_runtime_dependency "kwalify"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "mocha"
end
