# frozen_string_literal: true

require_relative "lib/faa_notams/version"

Gem::Specification.new do |spec|
  spec.name = "raad-notams"
  spec.version = FaaNotams::VERSION
  spec.authors = ["JP Silvashy"]
  spec.email = ["jp@raad.com", "jpsilvashy@gmail.com"]

  spec.summary = "Ruby wrapper for the FAA Notice to Airmen (NOTAM) API"
  spec.description = "A Ruby gem to interact with the FAA's NOTAM API, which provides real-time notifications of changes in the National Airspace System (NAS)."
  spec.homepage = "https://github.com/raad-labs/notams"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/#{spec.name}"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.glob("lib/**/*") + %w[LICENSE README.md CHANGELOG.md]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "yard", "~> 0.9"
  spec.add_development_dependency "webmock", "~> 3.14"
  spec.add_development_dependency "vcr", "~> 6.0"
end
