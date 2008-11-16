#!/usr/bin/ruby

# freevikings.rb
# igneus 18.1.2004

# FreeVikings project is trying to clone the brilliant
# Lost Vikings game.

# tell ruby to load libraries also from directory lib/:
$: << './lib'

# !!! more require-statements (SchwerEngine, Log4r) are at the end of this file
require 'fvdef.rb' # the FreeVikings module definition. Must be included first!
require 'getoptlong'
require 'level.rb'

include FreeVikings

# constants used for text formatting
LONG_OPT_W = 18
SHORT_OPT_W = 5
TERMINAL_W = 80
TEXT_W = TERMINAL_W - (LONG_OPT_W + 1 + SHORT_OPT_W + 1)

def print_help_and_exit
  File.open('HELP') do |f|
    f.each_line {|l| puts l}
  end
  puts

  puts "OPTIONS\n\n"

  short_options_summary = "-"
  long_options_summary = ""
  options_full = ""

  # constant OPTIONS_DEF is defined below
  OPTIONS_DEF.each do |o|
    short_options_summary.concat o[1].slice(1,1)

    long_options_summary.concat(" ["+o[0])
    if o[2] == GetoptLong::REQUIRED_ARGUMENT then
      long_options_summary.concat " "+o[4]
    elsif o[2] == GetoptLong::OPTIONAL_ARGUMENT then
      long_options_summary.concat " ["+o[4]+"]"
    end
    long_options_summary.concat "]"

    # a bit complicated process of formatting of full options' description:
    options_full.concat(o[0].ljust(LONG_OPT_W))
    options_full.concat o[1].ljust(SHORT_OPT_W)+" "

    l = o[3]
    first_line = true
    begin
      if l.size <= TEXT_W then
        l = l.ljust(TEXT_W)
        l = l.rjust(TERMINAL_W-2) if !first_line
        options_full.concat l+"\n"
        l = nil
      else
        # This would lead to infinite loop if there was some option comment
        # without spaces!

        # find last space before end of screen:
        i = 0
        TEXT_W.downto(0) {|x|
          if l[x].chr == " " then
            i = x
            break
          end
        }
        # now divide the text into two...
        s = l.slice(0, i).ljust(TEXT_W)
        s = s.rjust(TERMINAL_W-2) if !first_line
        options_full.concat s+"\n"
        l = l.slice(i, l.size)
        first_line = false
      end
    end while l
    options_full.concat "\n"
  end

  puts "ruby freevikings.rb [#{short_options_summary}]#{long_options_summary}"
  puts
  puts options_full

  exit
end

# Method used for options with on/off argument.
# Accepts String argument.
# If argument is positive, returns true, if negative, returns false,
# if unknown, raises ArgumentError

def on_off_option(argument)
  case argument.downcase
  when 'off', 'no', 'false'
    return false
  when 'on', 'yes', 'true' then
    return true
  else
    raise ArgumentError, "Unknown argument '#{argument}' of option '--sound' - only possible arguments are 'on' or 'off'"
  end
end

# Standard arguments for GetoptLong.new are Arrays of three members:
# long option, short option and argument flag.
# I added two more which are used to generate help:
# fourth is short descriptin and fifth argument description (only at options
# which receive argument).
# GetoptLong wouldn't receive such an extended argument, so before
# filling it all to GetoptLong, every Array is sliced.
OPTIONS_DEF = [
               ["--profile", "-P", GetoptLong::NO_ARGUMENT,
                "Profiling (only for development)"],

               ["--ruby-warnings", "-w", GetoptLong::NO_ARGUMENT,
                "Show ruby warnings"],
               
               ["--extensions", "-x", GetoptLong::NO_ARGUMENT,
                "DEPRECATED! Uses compiled C++ extensions instead of some of the critical classes. You must have built these extensions before you use this option."],
               
               ["--fps",     "-F", GetoptLong::NO_ARGUMENT,
                "Prints frames per second on the game screen"],
               
               ["--fullscreen", "-f", GetoptLong::NO_ARGUMENT,
                "Starts the game in the fullscreen mode"],
               
               ["--help",    "-h", GetoptLong::NO_ARGUMENT,
                "Prints out this help and halts."],
               
               ["--levelsuite", "-l", GetoptLong::REQUIRED_ARGUMENT,
                "Play levels from given levelsuite directory LEVELSITE_DIR instead of the default campaign.",
                "LEVELSUITE_DIR"],

               ["--v-unit",  "-u", GetoptLong::REQUIRED_ARGUMENT,
                "Requires an argument - real number higher than 0 influencing speed of movement of vikings and monsters (higher than 1 increases the speed). If you want to speed-up the game a bit, try e.g. 3; high numbers will cause interesting errors.",
                "NUMBER"],
               
               ["--delay",   "-d", GetoptLong::REQUIRED_ARGUMENT,
                "Number of milliseconds to sleep in every iteration of the main loop (it is very useful if the game runs on your computer with fps 40 or even higher - try 10 milliseconds)",
                "MILLISECONDS"],
               
               ["--startpassword", "-s", GetoptLong::REQUIRED_ARGUMENT,
                "Jump to a level with password PASSWORD (you can see the password always at the beginning of every level)",
                "PASSWORD"],
               
               ["--skip-menu", "-m", GetoptLong::NO_ARGUMENT,
                "Skip menu"],
               
               ["--skip-password", "-Z", GetoptLong::NO_ARGUMENT,
                "Don't display password at the beginning of level"],

               ["--sound", "-S", GetoptLong::REQUIRED_ARGUMENT,
                "Switch sound on/off", 
                "on|off"],

               ["--develmagic", "-D", GetoptLong::NO_ARGUMENT,
                "Enables some dark debugging magic"],

               ["--progressbar", "-B", GetoptLong::REQUIRED_ARGUMENT,
               "Show progressbar while loading",
               "on|off"]
              ]

# here is every argument-definition Array sliced to what GetoptLong wants;
# everything is then given into GetoptLong
options = GetoptLong.new(*(OPTIONS_DEF.collect {|o_array| o_array.slice(0,3)}))

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
        raise ArgumentError, "Argument of option '--v-unit' (-u) must be a real number higher than zero (given '#{argument}')"
      end
    when "--delay"
      FreeVikings::OPTIONS['delay'] = argument.to_f / 1000
    when "--startpassword"
      unless Level.valid_level_password?(argument)
        raise "'#{argument}' is not a valid location password."
      end
      
      FreeVikings::OPTIONS["startpassword"] = argument.upcase
    when "--skip-menu"
      FreeVikings::OPTIONS["menu"] = false
    when "--skip-password"
      FreeVikings::OPTIONS["display_password"] = false
    when "--sound"
      FreeVikings::OPTIONS['sound'] = on_off_option(argument)
    when "--develmagic"
      if FreeVikings::VERSION == 'DEV' then
        FreeVikings::OPTIONS['develmagic'] = true
      end
    when "--progressbar"
      FreeVikings::OPTIONS['progressbar_loading'] = on_off_option(argument)
    end
  end # options.each block
rescue GetoptLong::InvalidOption => ioex
  # normally Log4r is loaded a few lines below, but here it is needed...
  require 'log4r'
  require 'log4rsetupload'
  Log4r::Logger['init log'].fatal "Option error: "+ioex.message
  puts
  puts "'freevikings.rb -h' for detailed description of commandline options"
  exit
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

# All the huge requirements are done here, after options are processed,
# because it was terrible to type 'freevikings -h' (I can't remember that 
# option!) and wait 10 seconds until SchwerEngine and Log4r were loaded.

# If Log4r isn't installed on the system, load mocklog4r.rb instead.
begin
  require('log4r') 
  require('log4rsetupload')
rescue LoadError
  STDERR.puts "INFO: Log4r probably isn't installed on your system."
  require 'mocklog4r.rb'
end

if defined?(Gem) then
  # RubyGems + RUDL = crash; let's bypass gems
  puts "RubyGems found; loading RUDL with 'gem_original_require', not 'require'"
  gem_original_require 'RUDL'
else
  require 'RUDL'
end

require 'schwerengine/schwerengine.rb'
SchwerEngine.init(SchwerEngine::DISABLE_LOG4R_SETUP)
include SchwerEngine
SchwerEngine.config = FreeVikings

require 'initfv.rb' # Init class (just btw.: in Hebrew - which doesn't use syllables in the written text - 'Init' would probably be written the same as 'Anat', which is a goddess known from the Kenaan mythology)


$:.concat FreeVikings::CODE_DIRS

require "alternatives.rb"

# check versions of most important libraries:
FreeVikings.lib_versions_check

# This opens the game window, loads data and starts the game:
FreeVikings::Init.new
