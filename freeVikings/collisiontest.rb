# collisiontest.rb
# igneus 30.5.2005

module FreeVikings

=begin
= CollisionTest
CollisionTest is a module. It contains usually methods which accept
two arguments of type Rectangle. They all verify some fact about these
Rectangles' collision and return true or false.
(If you know well Ruby's standard library, you know the file fileutils.rb
and module FileTest, which provides similar service.)
If you don't know whether the two Rectangles collide, you should find it
out first. CollisionTest's methods don't control this. 
=end
  module CollisionTest

    def CollisionTest.bottom_collision?(collided, collider)
      collided.bottom < collider.bottom and \
      collided.top < collider.top
    end

    def bottom_collision?(collided, collider)
      CollisionTest.bottom_collision? collided, collider
    end
  end # module CollisionTest
end # module FreeVikings
