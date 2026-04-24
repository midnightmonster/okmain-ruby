# frozen_string_literal: true

require_relative "lib/okmain/version"

Gem::Specification.new do |spec|
  spec.name = "okmain"
  spec.version = Okmain::VERSION
  spec.authors = ["Joshua"]
  spec.summary = "Extract dominant colors from images using adaptive K-means in Oklab space"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir["lib/**/*.rb"] + ["okmain.gemspec"]
  spec.require_paths = ["lib"]

  spec.add_dependency "ruby-vips", "~> 2.1"
end
