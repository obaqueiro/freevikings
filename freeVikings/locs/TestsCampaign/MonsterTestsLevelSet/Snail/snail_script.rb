# snail_script.rb
# igneus 13.10.2005

# First test of monster class Snail.

load 'monsters/snail.rb'

TS = 40

LOCATION.add_sprite Snail.new([10*TS, 11*TS - Snail::HEIGHT])
