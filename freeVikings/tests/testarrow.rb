# testarrow.rb
# igneus 29.5.2005

# Testy pro Arrow.

require 'testsprite.rb'

class TestArrow < TestSprite

  def setup
    @sprite = FreeVikings::Arrow.new [90,90], 0
  end
end
