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

require 'initfv.rb' # Init class (just btw.: in Hebrew - which doesn't use syllables in the written text - 'Init' would probably be written the same as 'Anat', which is a goddess known from the Kenaan mythology)

require 'getoptlong'
require 'log4r'
require 'log4rsetupload'

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
                         ["--v-unit",  "-u", GetoptLong::REQUIRED_ARGUMENT],
                         ["--delay",   "-d", GetoptLong::REQUIRED_ARGUMENT],
                         ["--startpassword", "-s", GetoptLong::REQUIRED_ARGUMENT],
                         ["--skip-menu", "-m", GetoptLong::NO_ARGUMENT],
                         ["--skip-password", "-Z", GetoptLong::NO_ARGUMENT],
                         ["--develmagic", "-D", GetoptLong::NO_ARGUMENT]
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
      Log4r::Logger['init log'].error "Compiled extensions are never more supported. The program may not work well and crash soon."
    when "--fps"
      FreeVikings::OPTIONS['display_fps'] = true
    when "--fullscreen"
      FreeVikings::OPTIONS['fullscreen'] = true
    when "--help"
      print_help_and_exit
    when "--levelsuite"
      FreeVikings::OPTIONS['levelsuite'] = argument
    when "--v-unit"
      if argument.to_i > 0 then
        FreeVikings::OPTIONS['velocity_unit'] = argument.to_i
      else
        raise ArgumentError, "Argument of option --v-unit (-u) must be a real number higher than zero (given '#{argument}')"
      end
    when "--delay"
      FreeVikings::OPTIONS['delay'] = argument.to_i / 1000
    when "--startpassword"
      unless FreeVikings.valid_location_password?(argument)
        raise "'#{argument}' is not a valid location password."
      end
      
      FreeVikings::OPTIONS["startpassword"] = argument
    when "--skip-menu"
      FreeVikings::OPTIONS["menu"] = false
    when "--skip-password"
      FreeVikings::OPTIONS["display_password"] = false
    when "--develmagic"
      FreeVikings::OPTIONS['develmagic'] = true
    end
  end # options.each block
rescue GetoptLong::InvalidOption => ioex
  Log4r::Logger['init log'].fatal "Option error: "+ioex.message
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
FreeVikings::Init.new
