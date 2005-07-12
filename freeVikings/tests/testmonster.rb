# testmonster.rb
# igneus 16.7.2005

require 'test/unit'

require 'monster.rb'
require 'mockclasses.rb'
require 'tombstone.rb'

class TestMonster < Test::Unit::TestCase

  include FreeVikings
  include FreeVikings::Mock

  include FreeVikings::Monster

  def setup
    @location = MockLocation.new
@rect = Rectangle.new 0, 0, 60, 60
  end

  def testAddsTombStoneWhenDies
    destroy
    assert(@location.sprites.find {|s| s.kind_of? TombStone}, "When a Monster is dying, it must add a TombStone into a Location.")
  end
end
