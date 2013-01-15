# testsprite.rb
# igneus 21.2.2005

# Sada testovych pripadu pro tridu Sprite. S testy jsem otalel dlouho,
# ale ted chci tridu vycistit, tak budou testici potreba.

require 'testentity.rb'
require 'mockclasses.rb'

require 'sprite.rb'

class TestSprite < TestEntity

  include SchwerEngine

  def setup
    @entity = @sprite = Sprite.new(STARTPOS)
  end

#   def testKilledIsNotAlive
#     @sprite.destroy
#     assert_equal false, @sprite.alive?
#   end

  def testRegisterIn
    loc = Mock::MockLocation.new
    @sprite.register_in loc
    assert loc.sprites.include?(@sprite), "Sprite should have registered itself in the location."
  end

  def testRegisterIn
    @loc = Mock::MockLocation.new
    @sprite.register_in @loc
    assert @loc.sprites.include?(@sprite), "Sprite should have registered itself in the location."
  end
end
