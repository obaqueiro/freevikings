# testarrow.rb
# igneus 29.5.2005

# Testy pro Arrow.

require 'testsprite.rb'
require 'location.rb'
require 'mockclasses.rb'

class TestArrow < TestSprite

  def setup
    @arrow = @sprite = @entity = FreeVikings::Arrow.new([90,90], 0)
    @locat = Location.new(FreeVikings::Mock::TestingMapLoadStrategy.new)
  end

  def testValidLocationAttributeAfterAdded
    @locat.add_sprite @arrow
    assert_equal @locat, @arrow.location, "Arrow was added into the location, it should have the 'location' attribute set."
  end
end
