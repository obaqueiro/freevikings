#!/usr/bin/ruby -w

# freevikings.rb
# igneus 18.1.2004

# Pokus o reimplementaci hry Lost Vikings.

# Normy:
# Obrazek postavy : 80x100 px
# Dlazdice : 40x40 px

require 'fvdef.rb' # the FreeVikings module definition. Must be included first!

require 'getoptlong'
require 'log4r'

require 'init.rb'

include FreeVikings

def print_help_and_exit
  File.open('HELP') do |f|
    f.each_line {|l| puts l}
  end
  puts
  exit
end

options = GetoptLong.new(
                         ["--profile", "-p", GetoptLong::NO_ARGUMENT],
                         ["--extensions", "-x", GetoptLong::NO_ARGUMENT],
                         ["--fps",     "-F", GetoptLong::NO_ARGUMENT],
                         ["--fullscreen", "-f", GetoptLong::NO_ARGUMENT],
                         ["--help",    "-h", GetoptLong::NO_ARGUMENT],
                         ["--levelsuite", "-l", GetoptLong::REQUIRED_ARGUMENT]
)

begin
  options.each do |option, argument|
    case option
    when "--profile"
      FreeVikings::OPTIONS['profile'] = true
    when "--extensions"
      FreeVikings::OPTIONS['extensions'] = true       
    when "--fps"
      FreeVikings::OPTIONS['display_fps'] = true
    when "--fullscreen"
      FreeVikings::OPTIONS['fullscreen'] = true
    when "--help"
      print_help_and_exit
    when "--levelsuite"
      FreeVikings::OPTIONS['levelset'] = argument
    end
  end # options.each block
rescue GetoptLong::InvalidOption => ioex
  print "ERROR: "
  puts ioex.message
  puts
  print_help_and_exit
end

# This must be out of the block scope in which all the other
# options are processed.
# Ruby stdlib's 'profile' does terrible things when loaded in the block's
# scope (try yourself!).
if OPTIONS['profile'] then
  require 'profiler'

  END {
    Profiler__::print_profile(STDERR)
  }
end

$:.concat FreeVikings::CODE_DIRS

require "alternatives.rb"

FreeVikings::Init.new
