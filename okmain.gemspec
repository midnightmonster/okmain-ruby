# frozen_string_literal: true

require_relative "lib/okmain/version"

Gem::Specification.new do |spec|
  spec.name = "okmain"
  spec.version = Okmain::VERSION
  spec.authors = ["Joshua"]
  spec.summary = "Extract dominant colors from images using adaptive K-means in Oklab space"
  spec.homepage = "https://github.com/joshua/okmain-ruby"
  spec.licenses = ["MIT", "Apache-2.0"]
  spec.required_ruby_version = ">= 3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir["lib/**/*.rb"] + ["okmain.gemspec", "README.md", "LICENSE-MIT", "LICENSE-APACHE"]
  spec.require_paths = ["lib"]

  spec.add_dependency "ruby-vips", "~> 2.1"
end
