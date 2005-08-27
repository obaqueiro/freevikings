# first_script.rb
# igneus 31.7.2005

# Actually this isn't the first location script but a script for a location
# which is called First Location.
# (If you were interested which script was the first one, it was the
# script for Pyramis adventure. But the Slug from Pyramis adventure
# isn't the oldest enemy of the game. The first one was a Duck.
# At first it was a hardcoded monster and appeared in every location 
# at the same place. 
# It's nice. My freeVikings game is so young and it already has it's own 
# history :-) )

require 'lock.rb'
require 'key.rb'
require 'door.rb'

include FreeVikings

static_objects = LOCATION.map.static_objects

# Add the door:
door = Door.new(Rectangle.new(680,280,40,120))
static_objects.add door

# A lock which can open the door:
red_lock = Lock.new(Rectangle.new(830,320,30,30), Proc.new {door.open}, Lock::RED)
static_objects.add red_lock

# And a key to unlock the lock:
red_key = Key.new(Rectangle.new(380,100,30,30), Key::RED)
LOCATION.add_item red_key
