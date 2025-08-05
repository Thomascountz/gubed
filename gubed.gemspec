# frozen_string_literal: true

require_relative "lib/gubed/version"

Gem::Specification.new do |spec|
  spec.name = "gubed"
  spec.version = Gubed::VERSION
  spec.authors = ["Thomas Countz"]
  spec.email = ["thomascountz@gmail.com"]

  spec.summary = "Ruby CLI for managing and editing debugger breakpoints"
  spec.description = "Gubed is a standalone command-line tool for finding and managing debugger breakpoints (binding.pry, debugger, etc.) in Ruby codebases. Install globally with 'gem install gubed' and use in any project."
  spec.homepage = "https://github.com/thomascountz/gubed"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/thomascountz/gubed/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .standard.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
