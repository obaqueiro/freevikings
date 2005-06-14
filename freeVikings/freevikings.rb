#!/usr/bin/ruby -w

# freevikings.rb
# igneus 18.1.2004

# Pokus o reimplementaci hry Lost Vikings.

# Normy:
# Obrazek postavy : 80x100 px
# Dlazdice : 40x40 px

require 'getoptlong'
require 'log4r'

require 'init.rb'

# All the game's globals and classes are defined inside this module.
module FreeVikings
  GFX_DIR = 'gfx'
  OPTIONS = {}
end

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
                         ["--fps",     "-F", GetoptLong::NO_ARGUMENT],
                         ["--fullscreen", "-f", GetoptLong::NO_ARGUMENT],
                         ["--help",    "-h", GetoptLong::NO_ARGUMENT]
)

begin
  options.each do |option, argument|
    case option
    when "--profile"
      FreeVikings::OPTIONS['profile'] = true
    when "--fps"
      FreeVikings::OPTIONS['display_fps'] = true
    when "--fullscreen"
      FreeVikings::OPTIONS['fullscreen'] = true
    when "--help"
      print_help_and_exit
    end
  end # options.each block
rescue GetoptLong::InvalidOption => ioex
  print "ERROR: "
  puts ioex.message
  puts
  print_help_and_exit
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

require 'ext/Rectangle'
module FreeVikings
  include FreeVikings::Extensions::Rectangle
end

FreeVikings::Init.new
