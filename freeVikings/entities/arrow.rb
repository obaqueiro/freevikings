# arrow.rb
# igneus 20.2.2005

require 'shot.rb'

module FreeVikings

  WIDTH = 47
  HEIGHT = 12

  # Arrow is a Shot which is usually shot by a warior's bow.
  # By default it hurts any Monster, but the hunted type can be
  # changed by Arrow#hunted_type=

  class Arrow < Shot

    def initialize(start_pos, velocity)
      super([start_pos[0], start_pos[1], WIDTH, HEIGHT], velocity)

      @image = Model.new()
      @image.add_pair('left', Image.load('arrow_left.tga'))
      @image.add_pair('right', Image.load('arrow_right.tga'))
      @hunted_type = Monster
    end

    attr_accessor :hunted_type
  end # class Arrow
end # module FreeVikings
