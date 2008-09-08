# intro_script.rb
# igneus 2.9.2008

require 'door'
require 'lock'
require 'key'
require 'monsters/lift'
require 'monsters/piranha'

LOCATION << (door = Door.new([440,200]))

LOCATION << Lift.new(520,  [320, 160], LOCATION.theme)

LOCATION << Lock.new([460, 110], 
                     Proc.new {door.open},
                     Lock::GREEN)

LOCATION << Key.new([360, 280], Key::GREEN)

# Piranhas:
3.times {|i|
  LOCATION << Piranha.new([13*40+i*200, 8*40+20], Rectangle.new(13*40, 8*40+20, 22*40, 40)) 
}
