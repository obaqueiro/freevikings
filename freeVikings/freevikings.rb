#!/usr/bin/ruby -w
# freeVikings - the "Lost Vikings" clone
# Copyright (C) 2005 Jakub "igneus" Pavlik

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
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
