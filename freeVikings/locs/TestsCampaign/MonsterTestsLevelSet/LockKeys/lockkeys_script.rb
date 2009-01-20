# lockkeys_script.rb
# igneus 19.1.2009

# Locks which don't do anything - I made this level just to test 
# all the graphics

require 'lock'
require 'key'

ly = 360
ky = 200

[
 Lock.new([50, ly], Proc.new {}, Lock::RED),
 Key.new([350, ky], Key::BLUE),

 Lock.new([150, ly], Proc.new {}, Lock::GREEN),
 Key.new([150, ky], Lock::RED),

 Lock.new([250, ly], Proc.new {}, Lock::BLUE),
 Key.new([250, ky], Lock::GREEN)
].each {|o|
  LOCATION << o
}
