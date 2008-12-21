# climbin_script.rb
# igneus 21.12.2008

require 'ladder'
require 'switch'

TS = LOCATION.map.tile_size

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

      # 'switch''s ladder appears
      @location << @switches_and_ladders[switch]
    end
  end
end

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
