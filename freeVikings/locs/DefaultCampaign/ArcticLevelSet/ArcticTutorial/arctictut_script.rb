# arctictut_script.rb
# igneus 26.7.2005

# Script for location Arctic Tutorial.

require 'helpbutton.rb'
require 'switch.rb'
require 'apex.rb'
require 'bridge.rb'
require 'bear.rb'

include FreeVikings

#=== MAP POSITIONS RELATED CONSTANTS:

TILE_SIZE = 40

# normal floor of the corridor
FLOOR = TILE_SIZE * 10

# optimal y of a help button in the corridor (there's only one corridor 
# in the map)
OPTIMAL_HLP_Y = FLOOR - TILE_SIZE * 2 

#=== CLASSES:

class WideBridge < Bridge

  WIDTH = 200
  HEIGHT = 25

  def move(x,y)
    @rect = Rectangle.new(x, y, WIDTH, HEIGHT)
  end

  def init_images
    @image = get_theme_image('bridge_wide')
  end
end

#=== HELPERS: (In this location we have a lot of them. It's a tutorial 
#              location.)

help_data = []

help_data << [Rectangle.new(180,OPTIMAL_HLP_Y,30,30), 
              "Now, guys, all of you must reach the EXIT to get to another level. And you, player, press Ctrl or PgUp to switch between the vikings."]
help_data << [Rectangle.new(20*TILE_SIZE, OPTIMAL_HLP_Y, 30, 30),
              "The guy in the blue clothes is called Erik. He can jump. Try to press SPACE."]
help_data << [Rectangle.new((26*TILE_SIZE)+25, OPTIMAL_HLP_Y, 30, 30),
              "You can switch the switch over your head by pressing the 'S' key. Jump and try it!"]
help_data << [Rectangle.new(30*TILE_SIZE+5, OPTIMAL_HLP_Y, 30, 30),
              "Can you see the bear? Now you should know that Baleog (the green viking) has a sword. Switch to Baleog and press SPACE."]

help_data.each do |h|
  help = HelpButton.new(h[0], h[1], LOCATION)
  LOCATION << help
end

#=== MONSTERS:

# Adds an apex on the specified position
def create_apex(x,y)
  LOCATION << Apex.new(Rectangle.new(x, y, TILE_SIZE, TILE_SIZE), 
                       LOCATION.theme)
end

# Apexes in the large gap which the vikings must get over with a help
# of a bridge:
apex_positions = []
y = 13*TILE_SIZE
(21*TILE_SIZE).step(32*TILE_SIZE, TILE_SIZE) do |x| 
  create_apex(x,y)
end

# Apexes in small holes near the EXIT:
start_x = 1840
y = 440
3.times do |i|
  x = start_x + (i * (2 * TILE_SIZE))
  create_apex x, y
end

# A bear which tries to guard the EXIT (of course he has no chance)

start_walk = 33 * TILE_SIZE
end_walk = start_walk + (12 * TILE_SIZE)
half_trace = ((end_walk - start_walk)/2)
walk_length = half_trace - TILE_SIZE
center_bear_x = start_walk + half_trace - (WalkingBear::WIDTH / 2)
bear_y = FLOOR - WalkingBear::HEIGHT

bear = WalkingBear.new(Rectangle.new(center_bear_x, bear_y, WalkingBear::WIDTH, WalkingBear::HEIGHT), walk_length)
LOCATION << bear

# A nice cooperation of a Bridge and a Switch. There's only one bridge and 
# two terrible gaps filled in with apexes. The Switch moves the Bridge over 
# the first or the second gap.

x1 = TILE_SIZE*21
x2 = x1 + (7 * TILE_SIZE)
y = TILE_SIZE*10
bridge_positions = [[x1, y], [x2, y]]

bridge = WideBridge.new(bridge_positions[1], LOCATION.theme)
LOCATION << bridge

switch_proc = Proc.new do |state|
  if state then
    bridge.move bridge_positions[0][0], bridge_positions[0][1]
  else
    bridge.move bridge_positions[1][0], bridge_positions[1][1]
  end
end # switch_proc

switch = Switch.new([(26*TILE_SIZE)+25, OPTIMAL_HLP_Y-120], LOCATION.theme, false, switch_proc)
LOCATION << switch
