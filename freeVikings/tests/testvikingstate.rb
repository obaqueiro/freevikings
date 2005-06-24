# testvikingstate.rb
# igneus 11.3.2005

# Sada testovych pripadu pro stavove prechody vikingu.
# (Potrebuji provest par optimalizacnich uprav a chci mit jistotu, ze nenadelam
# neporadek.)

require 'testleggedspritestate.rb'

require 'vikingstate.rb'

class TestVikingState < TestLeggedSpriteState

  def setup
    @state = VikingState.new
  end
end
