# stairs_script.rb
# igneus 22.7.2006

require 'monsters/lift'
require 'helpbutton'
require 'monsters/animatedapex'
require 'switch'
require 'door'
require 'killtoy'

###### STAIRS HALL
# Erik must move lifts so that all the vikings can go down on them as
# on stairs.

# lifts which Erik must move so that they can be used as stairs down
bridge_y = []
680.step(1200,80) {|i| bridge_y.push i}

0.upto(2) {|i|
  LOCATION << Lift.new(2200 - i*(120+110), bridge_y, LOCATION.theme)
}

# the last lift can take you up to the help button
last_lift = Lift.new(2200 - 3*(120+110), [160]+bridge_y, LOCATION.theme)
last_lift.instance_eval {@dest = 1} # a dark-magic trick :-{
LOCATION << last_lift

# helpbutton; help text tells the player how to make stairs for the vikings
LOCATION << HelpButton.new([1520, 80], 
                           "Try to make stairs down to the gate "\
                           "using the lifts. All the vikings will be able "\
                           "to go down the stairs.", LOCATION)

# apexes which kill every viking who falls down under the stairs
6.times {|i|
  LOCATION << AnimatedApex.new([(40 + 3*i + 1) *40,34*40], LOCATION.theme)
  LOCATION << AnimatedApex.new([(40 + 3*i + 2) *40,34*40], LOCATION.theme)
}

# lift up to the lift-key hall
LOCATION << (interhall_lift = Lift.new(31*40, [35*40, 7*40], LOCATION.theme))
# switches to call the lift:
LOCATION << Switch.new([30*40+10,5*40], LOCATION.theme, false, 
                       Proc.new {interhall_lift.move_up})
LOCATION << Switch.new([34*40+10, 33*40], LOCATION.theme, false, 
                       Proc.new {interhall_lift.move_down})

# bonus on a hidden place
LOCATION << Killtoy.new([45*40, 3*40])

###### LIFT-KEY HALL
# Erik must move the special lifts so that they are on the emphasized places.
# The door to the next place is openned then.

# doors between the rooms with monsters
LOCATION << Door.new([14*40,32*40])
LOCATION << Door.new([22*40,32*40])

# door at the left top corner of the hall
LOCATION << Door.new([8*40,2*40])
