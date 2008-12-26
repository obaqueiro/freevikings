# troll_script.rb
# igneus 23.12.2008

require 'troll'

program = [:repeat, -1, [[:go, 60],
                         [:wait, 3],
                         [:go, 200],
                         [:wait, 2],
                         [:go, 13*40],
                         [:wait, 3],
                         [:go, 200],
                         [:wait, 3]]]
LOCATION << Troll.new([100, 11*40-Troll::HEIGHT], program)
