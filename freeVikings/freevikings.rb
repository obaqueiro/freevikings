#!/usr/bin/ruby

# freevikings.rb
# igneus 18.1.2004

# FreeVikings project is trying to clone the brilliant
# Lost Vikings game.

require 'fvdef.rb' # the FreeVikings module definition. Must be included first!

require 'schwerengine/schwerengine.rb'
SchwerEngine.init(SchwerEngine::DISABLE_LOG4R_SETUP)
include SchwerEngine
SchwerEngine.config = FreeVikings

require 'getoptlong'
require 'log4r'

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
                         ["--ruby-warnings", "-w", GetoptLong::NO_ARGUMENT],
                         ["--extensions", "-x", GetoptLong::NO_ARGUMENT],
                         ["--fps",     "-F", GetoptLong::NO_ARGUMENT],
                         ["--fullscreen", "-f", GetoptLong::NO_ARGUMENT],
                         ["--help",    "-h", GetoptLong::NO_ARGUMENT],
                         ["--levelsuite", "-l", GetoptLong::REQUIRED_ARGUMENT],
                         ["--startpassword", "-s", GetoptLong::REQUIRED_ARGUMENT]
)

begin
  options.each do |option, argument|
    case option
    when "--profile"
      FreeVikings::OPTIONS['profile'] = true
    when "--ruby-warnings"
      $VERBOSE = true
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
    when "--startpassword"
      unless FreeVikings.valid_location_password?(argument)
        raise "'#{argument}' is not a valid location password."
      end
      
      FreeVikings::OPTIONS["startpassword"] = argument
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

# This opens the game window, loads data and starts the game:
require 'initfv.rb'
FreeVikings::Init.new
