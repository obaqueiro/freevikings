# teleport_script.rb
# igneus 28.8.2008

require 'teleport.rb'

# Map of rooms:
#
######################################################################
# 1 - dark blue # 5 - light blue # 10 - red       # 2 - dark blue    #
######################################################################
# 12 - red      # 13 - final                      # 6 - light blue   #
#################                                 ####################
# 7 - light blue#                                 # 11 - red         #
######################################################################
# 4 - dark blue # 8 - light blue # 9 - red        # 3 - dark blue    #
######################################################################
#
# Rooms of the same colour are usually connected with a cycle of teleports
# and together they make up "sublevel";
# The only way through these "sublevels" is
# dark blue -> light blue -> red -> final

FIRST_FLOOR = 200
SECOND_FLOOR = 440

t1 = Teleport.new([200, FIRST_FLOOR - Teleport::HEIGHT])
t2 = Teleport.new([450, FIRST_FLOOR - Teleport::HEIGHT])

t3 = Teleport.new([50, SECOND_FLOOR - Teleport::HEIGHT])
t4 = Teleport.new([400, SECOND_FLOOR - Teleport::HEIGHT])

t1.destination = t3
t2.destination = t4
t3.destination = t4

LOCATION << t1 << t2 << t3 << t4
