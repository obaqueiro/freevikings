# stairs_script.rb
# igneus 22.7.2006

require 'monsters/lift'
require 'helpbutton'
require 'monsters/animatedapex'

bridge_y = []
680.step(1200,80) {|i| bridge_y.push i}

0.upto(2) {|i|
  LOCATION << Lift.new(2200 - i*(120+110), bridge_y, LOCATION.theme)
}

# the last lift can take you up to the help button
last_lift = Lift.new(2200 - 3*(120+110), [160]+bridge_y, LOCATION.theme)
last_lift.instance_eval {@dest = 1} # a dark-magic trick :-{
LOCATION << last_lift

LOCATION << HelpButton.new([1520, 80], 
                           "Try to make stairs down to the gate "\
                           "using the lifts. All the vikings will be able "\
                           "to go down the stairs.", LOCATION)

6.times {|i|
  LOCATION << AnimatedApex.new([(40 + 3*i + 1) *40,34*40], LOCATION.theme)
  LOCATION << AnimatedApex.new([(40 + 3*i + 2) *40,34*40], LOCATION.theme)
}
