#!/usr/bin/ruby -w

# freevikings.rb
# igneus 18.1.2004

# Pokus o reimplementaci hry Lost Vikings.

# Normy:
# Obrazek postavy : 80x100 px
# Dlazdice : 40x40 px

require 'game'

# ========================================================================= #
#          NEOBJEKTOVE METODY
# ========================================================================= #

# vraci pole ctyr prvku definujicich obdelnik centrovany predanymi 
# souradnicemi bodu, pokud tyto souradnice nejsou moc blizko okrajum
# plochy
# width, height - sirka a vyska plochy, po ktere se pohybujeme
# view_width, view_height - sirka a vyska zobrazeni
# center_coord - souradnice pozadovaneho stredu

def centered_view_rect(width, height, view_width, view_height, center_coord)
  # vypocet leve souradnice leveho horniho rohu:
  if center_coord[0] < (view_width / 2)
    # stred moc u zacatku
    top_left_left = 0
  elsif center_coord[0] > (width - (view_width / 2))
    # stred moc u konce
    top_left_left = width - view_width
  else
    top_left_left = center_coord[0] - (view_width / 2)
  end
  # vypocet svrchni souradnice leveho horniho rohu:
  if center_coord[1] < (view_height / 2)
    # stred moc u zacatku
    top_left_top = 0
  elsif center_coord[1] > (height - (view_height / 2))
    # stred moc u konce
    top_left_top = height - view_height
  else
    top_left_top = center_coord[1] - (view_height / 2)
  end
  bottom_right_left = top_left_left + view_width
  bottom_right_top = top_left_top + view_height
  [top_left_left, top_left_top, bottom_right_left, bottom_right_top]
end

# ========================================================================= #
#          HLAVNI PROGRAM
# ========================================================================= #
include FreeVikings

Game.new.game_loop



