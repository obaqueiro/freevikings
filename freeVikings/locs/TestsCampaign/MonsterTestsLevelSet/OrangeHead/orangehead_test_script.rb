# walkbear_test_script.rb
# igneus 24.9.2005

require 'monsters/orangehead.rb'
require 'talk.rb'

FLOOR = 440

talk_source = File.open(File.dirname(__FILE__) + '/small_talk.yaml')

LOCATION << OrangeHead.new([200, FLOOR - OrangeHead::HEIGHT],
                           Talk.new(talk_source))
