# frozen_string_literal: true

require "io/console"

module Gubed
  class BreakpointManager
    def initialize(root_path = ".")
      @scanner = BreakpointScanner.new(root_path)
      @breakpoints = []
      @current_index = 0
      @message = nil
    end

    def run
      refresh_breakpoints
      return puts "No breakpoints found." if @breakpoints.empty?

      loop do
        show_list
        puts @message if @message
        input = get_input

        case input
        when "q"
          break if exit_program?(input)
        when "r"
          refresh_breakpoints
          @current_index = 0
        when "t"
          toggle_comment
        when "d"
          delete_breakpoint
        when "v"
          show_context
        when "g"
          prompt_for_breakpoint
        when "j"
          move_down
        when "k"
          move_up
        when "h", "?"
          show_help
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

      width = @breakpoints.length.to_s.length
      @breakpoints.each_with_index do |bp, index|
        marker = (index == @current_index) ? ">" : " "
        status = bp.commented? ? "[#]" : "[ ]"
        number = (index + 1).to_s.rjust(width)

        puts "#{marker} #{number}. #{status} #{bp.type} #{bp.location}"
      end

      puts
      puts "Commands: [j]down [k]up [g]oto [v]iew [t]oggle [d]elete [r]efresh [q]uit [h]elp"
      puts "Selected: #{@current_index + 1} of #{@breakpoints.length}"
    end

    def get_input
      $stdin.getch
    end

    def prompt_for_breakpoint
      print "Go to breakpoint: "
      input = gets.chomp
      return if input.empty?

      num = input.to_i
      if num.between?(1, @breakpoints.length)
        @current_index = num - 1
      else
        @message = "Invalid selection: #{num}."
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

    def toggle_comment
      return if @breakpoints.empty?

      bp = @breakpoints[@current_index]

      modify_line(bp) do |line|
        if bp.commented?
          line.sub(/^(\s*)#\s*/, '\1')
        else
          line.sub(/^(\s*)/, '\1# ')
        end
      end

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

      refresh_breakpoints
      @current_index = [@current_index, @breakpoints.length - 1].min if @breakpoints.any?
    end

    def exit_program?(input)
      print "Press #{(input == "\e") ? "esc" : input} again to exit or any other key to continue: "
      response = $stdin.getch
      true if response == input
    end

    def modify_line(breakpoint)
      lines = File.readlines(breakpoint.file)
      lines[breakpoint.line_number - 1] = yield(lines[breakpoint.line_number - 1])
      File.write(breakpoint.file, lines.join)
    end

    def show_help
      puts
      puts "Commands:"
      puts "  j          - Move selection down"
      puts "  k          - Move selection up"
      puts "  g          - Go to a specific breakpoint by number"
      puts "  v          - Show context around breakpoint"
      puts "  t          - Toggle line comment on selected breakpoint"
      puts "  d          - Delete selected breakpoint"
      puts "  r          - Rescan for breakpoints"
      puts "  q          - Exit program"
      puts "  h, ?       - Show this help"
      puts
      puts "Legend: [ ] = Active, [#] = Commented"
      puts
      print "Press Enter to continue..."
      gets
    end
  end
end
