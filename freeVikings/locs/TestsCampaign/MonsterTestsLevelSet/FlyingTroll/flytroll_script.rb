# flytroll_script.rb
# igneus 26.12.2008

require 'flyingtroll'

LOCATION << FlyingTroll.new([50,50],
                            [:repeat, -1, [[:go, [60,100]],
                                           [:go, [400,250]],
                                           [:go, [350,240]],
                                           [:shoot],
                                           [:wait, 0.3],
                                           [:shoot]]])
