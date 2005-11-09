# arctictut_script.rb
# igneus 26.7.2005

# Script for location Arctic Tutorial.

require 'helpbutton.rb'
require 'switch.rb'
require 'monsters/apex.rb'
require 'monsters/bridge.rb'
require 'monsters/bear.rb'

include FreeVikings

#=== MAP POSITIONS RELATED CONSTANTS:

FLOOR = LOCATION.map.class::TILE_SIZE * 10 # normal floor of the corridor
OPTIMAL_HLP_Y = FLOOR - Map::TILE_SIZE * 2 # optimal y of a help button in the corridor (there's only one corridor inthe map)

#=== CLASSES:

class WideBridge < Bridge

  WIDTH = 200
  HEIGHT = 25

  def initialize(position, theme)
    super(position)
    @theme = theme
    @image = get_theme_image('bridge_wide')
  end

  def move(x,y)
    @rect = Rectangle.new(x, y, WIDTH, HEIGHT)
  end
end

#=== HELPERS: (In this location we have a lot of them. It's aa tutorial 
#              location.)

help_data = []

help_data << [FreeVikings::Rectangle.new(180,OPTIMAL_HLP_Y,30,30), 
              "Now, guys, all of you must reach the EXIT to get to another level. And you, player, press Ctrl or PgUp to switch between the vikings."]
help_data << [Rectangle.new(20*Map::TILE_SIZE, OPTIMAL_HLP_Y, 30, 30),
              "The guy in the red clothes is called Erik. He can jump. Try to press SPACE."]
help_data << [Rectangle.new((26*Map::TILE_SIZE)+25, OPTIMAL_HLP_Y, 30, 30),
              "You can switch the switch over your head by pressing the 'S' key. Jump and try it!"]
help_data << [Rectangle.new(30*Map::TILE_SIZE+5, OPTIMAL_HLP_Y, 30, 30),
              "Can you see the bear? Now you should know that Baleog (the green viking) has a sword. Switch to Baleog and press SPACE."]

help_data.each do |h|
  help = FreeVikings::HelpButton.new(h[0], h[1], LOCATION)
  LOCATION.add_active_object help
end

#=== MONSTERS:

# Apexes in the large gap which the vikings must get over with a help
# of a bridge:
def create_apex(x,y)
  a = Apex.new Rectangle.new(x, y, Map::TILE_SIZE, Map::TILE_SIZE), LOCATION.theme
  LOCATION.add_sprite a
end

apex_positions = []
y = 13*Map::TILE_SIZE
(21*Map::TILE_SIZE).step(32*Map::TILE_SIZE, Map::TILE_SIZE) {|x| create_apex(x,y)}

# Apexes in small holes near the EXIT:

start_x = 1840
y = 440
3.times do |i|
  x = start_x + (i * (2 * Map::TILE_SIZE))
  a = Apex.new(Rectangle.new(x, y, Map::TILE_SIZE, Map::TILE_SIZE), LOCATION.theme)
  LOCATION.add_sprite a
end

# A bear which tries to guard the EXIT (of course he has no chance)

start_walk = 33 * Map::TILE_SIZE
end_walk = start_walk + (12 * Map::TILE_SIZE)
half_trace = ((end_walk - start_walk)/2)
walk_length = half_trace - Map::TILE_SIZE
center_bear_x = start_walk + half_trace - (Bear::WIDTH / 2)
bear_y = FLOOR - Bear::HEIGHT

bear = WalkingBear.new(Rectangle.new(center_bear_x, bear_y, Bear::WIDTH, Bear::HEIGHT), walk_length)
LOCATION.add_sprite bear

# A nice cooperation of a Bridge and a Switch. There's only one bridge and 
# two terrible gaps filled in with apexes. The Switch moves the Bridge over 
# the first or the second gap.

x1 = Map::TILE_SIZE*21
x2 = x1 + (7 * Map::TILE_SIZE)
y = Map::TILE_SIZE*10
bridge_positions = [[x1, y], [x2, y]]

bridge = WideBridge.new(bridge_positions[1], LOCATION.theme)
LOCATION.add_sprite bridge

switch_proc = Proc.new do |state|
  if state then
    bridge.move bridge_positions[0][0], bridge_positions[0][1]
  else
    bridge.move bridge_positions[1][0], bridge_positions[1][1]
  end
end # switch_proc

switch = Switch.new([(26*Map::TILE_SIZE)+25, OPTIMAL_HLP_Y-120], LOCATION.theme, false, switch_proc)
LOCATION.add_active_object switch
