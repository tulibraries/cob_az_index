# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cob_az_index/version"

Gem::Specification.new do |spec|
  spec.name          = "cob_az_index"
  spec.version       = CobAzIndex::VERSION
  spec.authors       = ["David Kinzer"]
  spec.email         = ["dtkinzer@gmail.com"]

  spec.summary       = "Traject configuration and scripts for tul_cob az database"
  spec.description   = "Separates az indexing out of tulibraries/tul_cob repo"
  spec.homepage      = "https://github.com/tulibraries/cob_az_index"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = spec.homepage
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.executables << "cob_az_index"
  spec.require_paths = ["lib"]

  spec.add_dependency "traject", "~> 3.1"
  spec.add_dependency "traject_plus", ">= 1.1", "< 3.0"
  spec.add_dependency "httparty"

  spec.add_runtime_dependency("gli", "~> 2.18")

  spec.add_development_dependency "bundler", ">= 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "rubocop-rails"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-lcov"
end
