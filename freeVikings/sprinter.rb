# sprinter.rb
# igneus 1.2.2005

# Trida na miru pro Erika. Sprinter umi rychle behat a skakat, hlavou
# muze rozbijet zdi.

module FreeVikings

  class Sprinter < Viking

    def initialize(name, start_position)
      super(name, start_position)
      init_images
    end

    def space_func
      # @state = JumpingVikingState.new(self, @state)
    end

    private
    def init_images
      i_left = Image.new('erik_left.png')
      i_right = Image.new('erik_right.png')

      @image = ImageBank.new(self)

      @image.add_pair('onground_standing_left', i_left)
      @image.add_pair('onground_standing_right', i_right)
      @image.add_pair('onground_moving_left', i_left)
      @image.add_pair('onground_moving_right', i_right)
      @image.add_pair('falling_standing_right', i_right)
      @image.add_pair('falling_standing_left', i_left)
      @image.add_pair('falling_moving_right', i_right)
      @image.add_pair('falling_moving_left', i_left)

      @portrait = Portrait.new 'erik_face.tga', 'erik_face_unactive.gif', 'dead_face.png'
    end
  end # class
end # module
