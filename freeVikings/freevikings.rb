#!/usr/bin/ruby -w

# freevikings.rb
# igneus 18.1.2004

# Pokus o reimplementaci hry Lost Vikings.

# Normy:
# Obrazek postavy : 80x100 px
# Dlazdice : 40x40 px

require 'game'
#require 'profile'

module FreeVikings
  GFX_DIR = 'gfx'
end

include FreeVikings

Game.new.game_loop
