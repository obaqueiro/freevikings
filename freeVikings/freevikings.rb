#!/usr/bin/ruby -w

# freevikings.rb
# igneus 18.1.2004

# Pokus o reimplementaci hry Lost Vikings.

# Normy:
# Obrazek postavy : 80x100 px
# Dlazdice : 40x40 px

require 'getoptlong'

require 'game'

options = GetoptLong.new(
["--profile", "-p", GetoptLong::NO_ARGUMENT]
)

OPTS = {}

options.each do |option, argument|
  case option
  when "--profile"
    OPTS['profile'] = true
  end
end

if OPTS['profile'] then
require 'profile'
end

module FreeVikings
  GFX_DIR = 'gfx'
end

# load Log4r configuration:
require 'log4r/configurator'
Log4r::Configurator.load_xml_file('log4rconfig.xml')

include FreeVikings

Game.new.game_loop
