# arrowshooter_script.rb
# igneus 10.10.2005

require 'switch.rb'
require 'arrowshooter.rb'

shooter = ArrowShooter.new [8*40, 9*40]
LOCATION << shooter

switch = Switch.new([2*40, 5*40],
                    LOCATION.theme,
                    true,
                    Proc.new do |state|
                      if state
                        shooter.on
                      elsif not state
                        shooter.off
                      end
                    end)
LOCATION << switch
