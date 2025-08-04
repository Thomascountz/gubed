require 'find'

class Breakpoint
  attr_reader :file, :line_number, :content, :type

  def initialize(file, line_number, content, type)
    @file = file
    @line_number = line_number
    @content = content.strip
    @type = type
  end

  def commented?
    @content.strip.start_with?('#')
  end

  def location
    "#{@file}:#{@line_number}"
  end
end

class BreakpointScanner
  BREAKPOINT_PATTERNS = {
    'binding.pry' => /^\s*(?:#\s*)?binding\.pry\b/,
    'binding.irb' => /^\s*(?:#\s*)?binding\.irb\b/,
    'binding.break' => /^\s*(?:#\s*)?binding\.break\b/,
    'debugger' => /^\s*(?:#\s*)?debugger\b/,
    'byebug' => /^\s*(?:#\s*)?byebug\b/,
    'debug' => /^\s*(?:#\s*)?(?:require\s+['"]debug['"];\s*)?binding\.break\b/
  }.freeze

  RUBY_FILE_EXTENSIONS = %w[.rb .rake .gemspec].freeze

  def initialize(root_path = '.')
    @root_path = File.expand_path(root_path)
  end

  def scan
    breakpoints = []
    
    Find.find(@root_path) do |path|
      next if File.directory?(path)
      next unless ruby_file?(path)
      next if skip_file?(path)
      
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
    return false unless File.readable?(path)
    first_line = File.open(path, &:readline).strip rescue ''
    first_line.include?('ruby')
  end

  def skip_file?(path)
    path.include?('/.git/') || 
    path.include?('/vendor/') ||
    path.include?('/node_modules/') ||
    path.include?('/tmp/')
  end

  def scan_file(file_path)
    breakpoints = []
    
    File.readlines(file_path).each_with_index do |line, index|
      BREAKPOINT_PATTERNS.each do |type, pattern|
        if line.match(pattern)
          breakpoints << Breakpoint.new(
            file_path, 
            index + 1, 
            line.chomp, 
            type
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