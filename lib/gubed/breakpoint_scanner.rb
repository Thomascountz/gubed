# frozen_string_literal: true

require "find"

module Gubed
  Breakpoint = Data.define(:file, :line_number, :content, :type) do
    def initialize(file:, line_number:, content:, type:)
      super(file: file, line_number: line_number, content: content.strip, type: type)
    end

    def commented?
      content.start_with?("#")
    end

    def location
      "#{file}:#{line_number}"
    end
  end

  class BreakpointScanner
    BREAKPOINT_PATTERNS = {
      "binding.pry" => /^\s*(?:#\s*)?binding\.pry\b/,
      "binding.irb" => /^\s*(?:#\s*)?binding\.irb\b/,
      "binding.break" => /^\s*(?:#\s*)?binding\.break\b/,
      "debugger" => /^\s*(?:#\s*)?debugger\b/,
      "byebug" => /^\s*(?:#\s*)?byebug\b/,
      "debug" => /^\s*(?:#\s*)?(?:require\s+['"]debug['"];\s*)?binding\.break\b/
    }.freeze

    RUBY_FILE_EXTENSIONS = %w[.rb .rake .gemspec].freeze
    DIR_TO_SKIP = %w[.git vendor node_modules tmp].freeze

    def initialize(root_path = ".")
      @root_path = File.expand_path(root_path)
    end

    def scan
      breakpoints = []

      Find.find(@root_path) do |path|
        if File.directory?(path)
          Find.prune if DIR_TO_SKIP.any? { |dir| path.include?(dir) }
          next
        end

        next unless ruby_file?(path)

        breakpoints.concat(scan_file(path))
      end

      breakpoints.sort_by(&:location)
    end

    private

    def ruby_file?(path)
      RUBY_FILE_EXTENSIONS.any? { |ext| path.end_with?(ext) } ||
        (File.executable?(path) && ruby_shebang?(path))
    end

    def ruby_shebang?(path)
      first_line = begin
        File.open(path, &:readline).strip
      rescue
        ""
      end
      first_line.include?("ruby")
    end

    def scan_file(file_path)
      breakpoints = []

      File.foreach(file_path).each_with_index do |line, index|
        BREAKPOINT_PATTERNS.each do |type, pattern|
          if line.match(pattern)
            breakpoints << Breakpoint.new(
              file: file_path,
              line_number: index + 1,
              content: line.chomp,
              type: type
            )
            break
          end
        end
      end

      breakpoints
    rescue => e
      puts "Warning: Could not scan #{file_path}: #{e.message}"
      []
    end
  end
end
