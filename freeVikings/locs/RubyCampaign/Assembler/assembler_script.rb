# assembler_script.rb
# igneus 28.8.2008

require 'teleport.rb'
require 'door.rb'

door = Door.new [21*40,9*40]
LOCATION << door

# Teleports in the dark blue rooms.
# Teleport cycle: t1 -> t2 -> t3 -> t4 -> back to t1 ...
t1 = Teleport.new [260, 360]
t2 = Teleport.new [80*40, 20*40-Teleport::HEIGHT]
t3 = Teleport.new [80*40, 83*40-Teleport::HEIGHT]
t4 = Teleport.new [8*40, 83*40-Teleport::HEIGHT]

t1.destination = t2
t2.destination = t3
t3.destination = t4
t4.destination = t1

LOCATION << t1 << t2 << t3 << t4
