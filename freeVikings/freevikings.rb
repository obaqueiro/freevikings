#!/home/deti/igneus/dist/ruby-1.8.0/ruby

# freevikings.rb
# igneus 18.1.2004

# Pokus o reimplementaci hry Lost Vikings.

# Normy:
# Obrazek postavy : 80x100 px
# Dlazdice : 40x40 px

require 'game'

module FreeVikings
  GFX_DIR = 'gfx'
end

include FreeVikings

Game.new.game_loop



