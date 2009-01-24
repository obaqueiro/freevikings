# climbin_script.rb
# igneus 21.12.2008

require 'ladder'
require 'switch'
require 'flyingtroll'
require 'door'
require 'lock'
require 'key'
require 'killtoy'
require 'apex'

TS = LOCATION.map.tile_size

# classes, class tuning etc. =================================================

class FreeVikings::Ladder

  # when Ladder is out of Location, it's Rectangle is empty - dirty trick
  # to achieve right behavior: viking must fall when ladder disappears,
  # but he has reference of a ladder and doesn't check if it is still 
  # in the location - it isn't very usual that ladder disappears...
  # (this level is rather an exception)

  alias_method :_initialize, :initialize

  def initialize(position, bits)
    _initialize(position, bits)
    @hidden_rect = @rect
    @rect = Rectangle.new 0,0,0,0
  end

  alias_method :_location=, :location=

  def location=(loc)
    _location = loc
    if loc.class == Location then
      @rect = @hidden_rect
    else 
      @rect = Rectangle.new 0,0,0,0
    end
  end
end

class FreeVikings::Switch

  # we need a method to switch the Switch without calling it's action:

  def silent_switch
    @state = (not @state)
  end
end

class TrickyLadderSystem
  def initialize(location)
    @location = location
    @switches_and_ladders = {}
  end

  def add_pair(switch, ladder)
    @switches_and_ladders[switch] = ladder
  end

  def switch_changed(switch)
    if switch.off? then
      @location.delete_active_object @switches_and_ladders[switch]
      @location.delete_static_object @switches_and_ladders[switch]

      @switches_and_ladders.each_pair {|sw, ld|
        next if sw == switch

        if sw.off? then
          sw.silent_switch
          @location << ld
          break # just one switch should be off
        end
      }
    elsif switch.on? then
      # select random ladder to disappear
      sws = @switches_and_ladders.keys
      begin
        sw = sws[rand(sws.size)]
      end while sw == switch

      # let it disappear
      sw.silent_switch
      @location.delete_active_object @switches_and_ladders[sw]
      @location.delete_static_object @switches_and_ladders[sw]

      # 'switch''s ladder appears
      @location << @switches_and_ladders[switch]
    end
  end
end

# FlyingTroll modified so that he has an item which he leaves on the place
# of his death

class FreeVikings::FlyingTroll

  attr_accessor :my_treasure

  alias_method :_destroy, :destroy

  def destroy
    c = @rect.center
    @my_treasure.rect.left = c[0]
    @my_treasure.rect.top = c[1]

    @location << @my_treasure

    _destroy
  end
end

# content ====================================================================

lsys = TrickyLadderSystem.new(LOCATION)

# ladders:
ladders = [l1 = Ladder.new([6*TS, 1*TS], 26),
           l2 = Ladder.new([12*TS, 1*TS], 26),
           l3 = Ladder.new([21*TS, 1*TS], 26),
           l4 = Ladder.new([26*TS, 1*TS], 26)]
LOCATION << l1 << l2 << l4

# group of switches:
# one of them at a time is off; all others are on (whenever you switch some 
# off, the previous one is switched on automatically; when you switch the
# off one on, random one is switched off);
# they are connected with ladders: just three of them are visible (and usable) 
# at a time
switches = [s1 = Switch.new([14.5*TS,18*TS], LOCATION.theme, true, 
                            Proc.new {|st,sw| lsys.switch_changed(sw)}),
            s2 = Switch.new([16*TS,18*TS], LOCATION.theme, true, 
                            Proc.new {|st,sw| lsys.switch_changed(sw)}),
            s3 = Switch.new([18*TS,18*TS], LOCATION.theme, false, 
                            Proc.new {|st,sw| lsys.switch_changed(sw)}),
            s4 = Switch.new([19.5*TS,18*TS], LOCATION.theme, true, 
                            Proc.new {|st,sw| lsys.switch_changed(sw)})]
switches.each {|s|
  LOCATION << s
}

0.upto(3) {|i| 
  lsys.add_pair(switches[i], ladders[i])
}

# door which closes way to the exit
edoor = Door.new([4*TS, 24*TS])
edoor.instance_eval { @locked_times = 2 }
def edoor.unlock
  @locked_times -= 1
  if @locked_times <= 0 then
    self.open
  end
end
LOCATION << edoor

# two locks which together open 'edoor'
LOCATION << Lock.new([5*TS+5, 24*TS+10], Proc.new {edoor.unlock}, Lock::RED)
LOCATION << Lock.new([5*TS+5, 24*TS+50], Proc.new {edoor.unlock}, Lock::GREEN)

# Two flying trolls; each has his half of the space, where he flies.
# They have keys.
program1 = [:repeat, -1, [[:repeat, 2, [[:go, [8*TS,2*TS]],
                                        [:go, [16*TS,4*TS]],
                                        [:go, [26*TS,2*TS]]],
                          [:go, [21*TS, 12*TS]],
                          [:go, [10*TS,13*TS]]]]]
t1 = FlyingTroll.new([6*TS,5*TS], program1)
t1.my_treasure = Key.new([0,0], Key::RED)

program2 = [:repeat, -1, [[:go, [6*TS,18*TS]],
                          [:go, [17*TS,14*TS]],
                          [:go, [26*TS, 20*TS]],
                          [:go, [26*TS, 23*TS]],
                          [:go, [13*TS, 23*TS+10]]]]
t2 = FlyingTroll.new([6*TS,18*TS], program2)
t2.my_treasure = Key.new([0,0], Key::GREEN)

LOCATION << t1 << t2

# Apexes under the ladders
LOCATION << ApexRow.new([5*TS,28*TS], 11, LOCATION.theme)
LOCATION << ApexRow.new([19*TS,28*TS], 10, LOCATION.theme)

# A useful item...
LOCATION << Killtoy.new([27*TS,2*TS])

# Ladder to the exit:
LOCATION << Ladder.new([55, 12*TS], 15)
