# manyitems_script.rb
# igneus 16.8.2008

require 'key.rb'
require 'apple.rb'
require 'killtoy.rb'
require 'healingpotion.rb'

items = [Killtoy, Key, Apple, HealingPotion]

TILE_SIZE = 40
LOCATION_WIDTH = 36 * TILE_SIZE
FLOOR_Y = 11 * TILE_SIZE
ITEMS_Y = FLOOR_Y - 55
ITEM_DISTANCE = 80
BORDER = 60 # distance between map edge and first item

num_items = (LOCATION_WIDTH - 2*BORDER) / ITEM_DISTANCE
0.upto(num_items) do |i|
  item_class = items[rand(items.size)]
  r = rand(50) - 100 # random number <-50 .. 50>
  x = BORDER + i*ITEM_DISTANCE + r
  y = ITEMS_Y + r
  LOCATION << item_class.new([x,y])
end
