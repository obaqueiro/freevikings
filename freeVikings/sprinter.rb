# sprinter.rb
# igneus 1.2.2005

# Trida na miru pro Erika. Sprinter umi rychle behat a skakat, hlavou
# muze rozbijet zdi.

module FreeVikings

  class Sprinter < Viking

    def initialize(name="")
      super(name)
      init_images
    end

    def space_func
      @state = JumpingVikingState.new(self, @state)
    end

    private
    def init_images
      i_left = Image.new('erik_left.png')
      i_right = Image.new('erik_right.png')
      i_standing = Image.new('erik_standing.png')

      @image = ImageBank.new(self)

      @image.add_pair('standing_', i_standing)
      @image.add_pair('standing_left', i_left)
      @image.add_pair('standing_right', i_right)
      @image.add_pair('moving_left', i_left)
      @image.add_pair('moving_right', i_right)
      @image.add_pair('jumping', i_standing)
      @image.add_pair('stucked_', i_standing)
      @image.add_pair('stucked_left', i_left)
      @image.add_pair('stucked_right', i_right)
      @image.add_pair('falling_', i_standing)
      @image.add_pair('falling_left', i_left)
      @image.add_pair('falling_right', i_right)
      @image.add_pair('dead', Image.new('dead.png'))
    end
  end # class
end # module
