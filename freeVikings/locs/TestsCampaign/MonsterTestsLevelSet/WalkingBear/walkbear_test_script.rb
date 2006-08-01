# walkbear_test_script.rb
# igneus 24.9.2005

require 'monsters/bear.rb'

FLOOR = 440

LOCATION << WalkingBear.new([200, FLOOR - WalkingBear::HEIGHT], 150)
