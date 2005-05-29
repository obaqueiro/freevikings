#!/usr/bin/ruby -w

# freevikings.rb
# igneus 18.1.2004

# Pokus o reimplementaci hry Lost Vikings.

# Normy:
# Obrazek postavy : 80x100 px
# Dlazdice : 40x40 px

require 'getoptlong'

# All the game's globals and classes are defined inside this module.
module FreeVikings
  GFX_DIR = 'gfx'
  OPTIONS = {}
end

include FreeVikings

options = GetoptLong.new(
                         ["--profile", "-p", GetoptLong::NO_ARGUMENT],
                         ["--fps",     "-F", GetoptLong::NO_ARGUMENT],
                         ["--help",    "-h", GetoptLong::NO_ARGUMENT]
)

options.each do |option, argument|
  case option
  when "--profile"
    FreeVikings::OPTIONS['profile'] = true
  when "--fps"
    FreeVikings::OPTIONS['display_fps'] = true
  when "--help"
    File.open('HELP') do |f|
      f.each_line {|l| puts l}
    end
    puts
    exit
  end
end

# Commandline arguments which weren't processed as options remained
# in the ARGV array. We consider them filenames of XML documents
# describing FreeVikings location.
unless ARGV.empty?
  FreeVikings::OPTIONS['locations'] = ARGV
else
  FreeVikings::OPTIONS['locations'] = []
end

# This must be out of the block scope in which all the other
# options are processed.
# Ruby stdlib's 'profile' does terrible things when loaded in the block's
# scope (try yourself!).
if OPTIONS['profile'] then
  require 'profile'
end

# load Log4r configuration:
require 'log4r'
require 'log4r/configurator'
Log4r::Configurator.load_xml_file('log4rconfig.xml')
Log4r::Logger.global.level = Log4r::OFF # vystup testu nesmi byt rusen

# All the setup's done, we can start the game.
require 'game'

Game.new.game_loop
