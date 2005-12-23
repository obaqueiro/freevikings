# testcollisiontest.rb
# igneus 30.5.2005

# Sada testovych pripadu pro CollisionTest.
# CollisionTest je modul obsahujici metody, ktere zjistuji
# vlastnosti vzajemne polohy dvou Rectanglu.

require 'test/unit'

require 'collisiontest.rb'

class TestCollisionTest < Test::Unit::TestCase

  include FreeVikings

  include FreeVikings::CollisionTest

  def testBottomCollision
    # dva ctverce 50x50, jsou pod sebou a prekryvaji se 5px vysokym pasem
    top = Rectangle.new     0,  0,  50, 50
    bottom = Rectangle.new  0,  45, 50, 50
    assert bottom_collision?(top, bottom), "Bottom collides with Top on Top's bottom."
  end
end
