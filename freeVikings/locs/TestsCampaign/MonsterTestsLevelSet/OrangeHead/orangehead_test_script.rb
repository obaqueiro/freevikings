# walkbear_test_script.rb
# igneus 24.9.2005

require 'monsters/orangehead.rb'

FLOOR = 440

MONSTERS << OrangeHead.new([200, FLOOR - OrangeHead::HEIGHT])
