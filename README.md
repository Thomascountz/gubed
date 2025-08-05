# Gubed

A command-line tool for managing debugger breakpoints in Ruby projects. Find, comment, uncomment, and delete debugging statements like `binding.pry`, `debugger`, `binding.irb`, and more.

## Installation

```bash
gem install gubed
```

## Usage

Run `gubed` in any Ruby project directory to scan for debugging breakpoints:

```bash
$ gubed --help

gubed                    # Scan current directory
gubed /path/to/project   # Scan specific directory
```

### Interactive Mode

Once Gubed finds breakpoints, you can:

- Navigate with `j` (down) and `k` (up)
- Press `t` to toggle comment/uncomment breakpoints
- Press `d` to delete breakpoints
- Press `v` to view surrounding code context
- Press `g` to go to a specific breakpoint by number
- Press `r` to refresh/rescan breakpoints
- Press `q` to quit
- Press `h` or `?` for help

### Supported Breakpoint Types

These are found based on regex.

- `binding.pry`
- `binding.irb`
- `binding.break`
- `debugger`
- `byebug`

## Example

```bash
$ gubed
Gubed - Ruby Breakpoint Manager
========================================

>  1. [#] binding.irb /Users/thomas.countz/Code/experiments/gubed/examples/calculator.rb:14
   2. [ ] binding.break /Users/thomas.countz/Code/experiments/gubed/examples/calculator.rb:19
   3. [ ] binding.pry /Users/thomas.countz/Code/experiments/gubed/examples/calculator.rb:3
   4. [#] debugger /Users/thomas.countz/Code/experiments/gubed/examples/calculator.rb:8
   5. [#] debugger /Users/thomas.countz/Code/experiments/gubed/examples/sample_app.rb:11
   6. [ ] debugger /Users/thomas.countz/Code/experiments/gubed/examples/sample_app.rb:15
   7. [#] binding.break /Users/thomas.countz/Code/experiments/gubed/examples/sample_app.rb:17
   8. [ ] binding.break /Users/thomas.countz/Code/experiments/gubed/examples/sample_app.rb:22
   9. [ ] byebug /Users/thomas.countz/Code/experiments/gubed/examples/sample_app.rb:25
  10. [ ] binding.pry /Users/thomas.countz/Code/experiments/gubed/examples/sample_app.rb:4
  11. [#] binding.irb /Users/thomas.countz/Code/experiments/gubed/examples/sample_app.rb:9

Commands: [j]down [k]up [g]oto [v]iew [t]oggle [d]elete [r]efresh [q]uit [h]elp
Selected: 1 of 11
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Run `rake test` to run the tests.

## License

MIT License Copyright (c) 2025 Thomas Countz
