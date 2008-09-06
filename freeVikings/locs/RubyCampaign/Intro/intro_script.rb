# intro_script.rb
# igneus 2.9.2008

require 'door'
require 'lock'
require 'key'
require 'monsters/bridge'
require 'monsters/lift'

LOCATION << (door = Door.new([440,240]))

# LOCATION << (bridge = Bridge.new([320, 160], LOCATION.theme))

LOCATION << Lift.new(520,  [360, 160], LOCATION.theme)

# LOCATION << Lock.new([450, 110], 
#                      Proc.new {bridge.unregister_in LOCATION}, 
#                      Lock::RED)
LOCATION << Lock.new([460, 110], 
                     Proc.new {door.open},
                     Lock::GREEN)

# LOCATION << Key.new([320, 110], Key::RED)
LOCATION << Key.new([360, 280], Key::GREEN)

