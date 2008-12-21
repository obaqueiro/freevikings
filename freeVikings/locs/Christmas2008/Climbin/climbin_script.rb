# climbin_script.rb
# igneus 21.12.2008

require 'ladder'
require 'switch'

TS = LOCATION.map.tile_size

# ladders:
l1 = Ladder.new([6*TS, 1*TS], 26)
l2 = Ladder.new([12*TS, 1*TS], 26)
l3 = Ladder.new([21*TS, 1*TS], 26)
l4 = Ladder.new([26*TS, 1*TS], 26)

LOCATION << l1 << l2 << l3 << l4

# group of switches:
# one of them at a time is off; all others are on (whenever you switch some 
# off, the previous one is switched on automatically; when you switch the
# off one on, random one is switched off);
# they are connected with ladders: just three of them are visible (and usable) 
# at a time
s1 = Switch.new [14.5*TS,18*TS], LOCATION.theme, true, Proc.new{|on| }
s2 = Switch.new [16*TS,18*TS], LOCATION.theme, true, Proc.new{|on| }
s3 = Switch.new [18*TS,18*TS], LOCATION.theme, true, Proc.new{|on| }
s4 = Switch.new [19.5*TS,18*TS], LOCATION.theme, true, Proc.new{|on| }

LOCATION << s1 << s2 << s3 << s4
