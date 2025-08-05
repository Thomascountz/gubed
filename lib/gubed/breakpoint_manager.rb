# frozen_string_literal: true

require "readline"

module Gubed
  class BreakpointManager
    def initialize(root_path = ".")
      @scanner = BreakpointScanner.new(root_path)
      @breakpoints = []
      @current_index = 0
    end

    def run
      refresh_breakpoints
      return puts "No breakpoints found." if @breakpoints.empty?

      loop do
        show_list
        input = get_input

        case input
        when "q", "quit", "exit"
          break
        when "r", "refresh"
          refresh_breakpoints
          @current_index = 0
        when "c", "comment"
          toggle_comment(true)
        when "u", "uncomment"
          toggle_comment(false)
        when "d", "delete"
          delete_breakpoint
        when "v", "view"
          show_context
        when /^\d+$/
          select_breakpoint(input.to_i)
        when "j", "down"
          move_down
        when "k", "up"
          move_up
        when "h", "help", "?"
          show_help
        else
          puts "Unknown command. Type 'h' for help."
        end
      end
    end

    private

    def refresh_breakpoints
      print "Scanning..."
      @breakpoints = @scanner.scan
      puts " found #{@breakpoints.length} breakpoints"
      @current_index = [@current_index, @breakpoints.length - 1].min if @breakpoints.any?
    end

    def show_list
      system("clear") || system("cls")
      puts "Gubed - Ruby Breakpoint Manager"
      puts "=" * 40
      puts

      if @breakpoints.empty?
        puts "No breakpoints found."
        return
      end

      @breakpoints.each_with_index do |bp, index|
        marker = (index == @current_index) ? ">" : " "
        status = bp.commented? ? "[C]" : "[A]"

        puts "#{marker} #{index + 1}. #{status} #{bp.type} #{bp.location}"
      end

      puts
      puts "Commands: [j]down [k]up [v]iew [c]omment [u]ncomment [d]elete [r]efresh [q]uit [h]elp"
      puts "Selected: #{@current_index + 1} of #{@breakpoints.length}"
      print "> "
    end

    def get_input
      Readline.readline("", true)&.strip&.downcase || ""
    end

    def select_breakpoint(num)
      if num.between?(1, @breakpoints.length)
        @current_index = num - 1
      else
        puts "Invalid selection. Press Enter to continue."
        gets
      end
    end

    def move_down
      @current_index = (@current_index + 1) % @breakpoints.length
    end

    def move_up
      @current_index = (@current_index - 1) % @breakpoints.length
    end

    def show_context
      return if @breakpoints.empty?

      bp = @breakpoints[@current_index]
      lines = File.readlines(bp.file)

      puts
      puts "Context for #{bp.location}:"
      puts "-" * 40

      start_line = [bp.line_number - 6, 1].max
      end_line = [bp.line_number + 4, lines.length].min

      (start_line..end_line).each do |line_num|
        line_index = line_num - 1
        content = lines[line_index].rstrip
        marker = (line_num == bp.line_number) ? ">>> " : "    "
        puts "#{marker}#{line_num}: #{content}"
      end

      puts
      print "Press Enter to continue..."
      gets
    end

    def toggle_comment(comment_out)
      return if @breakpoints.empty?

      bp = @breakpoints[@current_index]

      if comment_out && bp.commented?
        puts "Already commented. Press Enter to continue."
        gets
        return
      end

      if !comment_out && !bp.commented?
        puts "Not commented. Press Enter to continue."
        gets
        return
      end

      modify_line(bp) do |line|
        if comment_out
          line.sub(/^(\s*)/, '\1# ')
        else
          line.sub(/^(\s*)#\s*/, '\1')
        end
      end

      puts "#{comment_out ? "Commented" : "Uncommented"} breakpoint. Press Enter to continue."
      gets
      refresh_breakpoints
    end

    def delete_breakpoint
      return if @breakpoints.empty?

      bp = @breakpoints[@current_index]

      print "Delete breakpoint at #{bp.location}? (y/N): "
      response = gets.chomp.downcase

      return unless response == "y" || response == "yes"

      lines = File.readlines(bp.file)
      lines.delete_at(bp.line_number - 1)
      File.write(bp.file, lines.join)

      puts "Deleted breakpoint. Press Enter to continue."
      gets
      refresh_breakpoints
      @current_index = [@current_index, @breakpoints.length - 1].min if @breakpoints.any?
    end

    def modify_line(breakpoint)
      lines = File.readlines(breakpoint.file)
      lines[breakpoint.line_number - 1] = yield(lines[breakpoint.line_number - 1])
      File.write(breakpoint.file, lines.join)
    end

    def show_help
      puts
      puts "Commands:"
      puts "  j, down    - Move selection down"
      puts "  k, up      - Move selection up"
      puts "  1-9        - Jump to breakpoint number"
      puts "  v, view    - Show context around breakpoint"
      puts "  c, comment - Comment out selected breakpoint"
      puts "  u, uncomment - Uncomment selected breakpoint"
      puts "  d, delete  - Delete selected breakpoint"
      puts "  r, refresh - Rescan for breakpoints"
      puts "  q, quit    - Exit program"
      puts "  h, help    - Show this help"
      puts
      puts "Legend: [A] = Active, [C] = Commented"
      puts
      print "Press Enter to continue..."
      gets
    end
  end
end
