# locs/TestsCampaign/MonsterTestsLevelSet/Ladder/ladder_script.rb
# igneus 16.11.2008

require 'ladder'

LOCATION << Ladder.new([480, 280], 4)

# useless ladder on the right
LOCATION << Ladder.new([640, 40], 10)

# ladder to the exit
LOCATION << Ladder.new([250, 40], 6)

# ladder to test special cases: 
# bottom end of ladder over solid surface and
# top end of ladder not far from ceiling
LOCATION << Ladder.new([50, 100], 5)
