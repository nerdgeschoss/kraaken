# frozen_string_literal: true

require_relative "lib/kraaken/version"

Gem::Specification.new do |spec|
  spec.name = "kraaken"
  spec.version = Kraaken::VERSION
  spec.authors = ["Jens Ravens"]
  spec.email = ["jens@nerdgeschoss.de"]

  spec.summary = "Deploy stuff with docker. The easy way."
  spec.description = "Kraaken helps you deploy your applications with docker and traefik."
  spec.homepage = "https://github.com/nerdgeschoss/kraaken"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?("bin/", "test/", "spec/", "features/", ".git", ".circleci", "appveyor", "Gemfile")
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 7.0"
  spec.add_dependency "net-ssh", "~> 7.0"
  spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "hcloud", "~> 1.2"
  spec.add_dependency "faraday", "~> 2.7"
  spec.add_dependency "zeitwerk", "~> 2.5"
  spec.add_dependency "ruby-progressbar", "~> 1.13"
end
