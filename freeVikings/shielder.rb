# shielder.rb
# igneus 1.2.2005

# Trida na miru pro Olafa. Shielder ma stit, umi se jim branit a plachtit
# na nem.

module FreeVikings

  class Shielder < Viking

    def initialize(name="")
      super(name)
      init_images
    end

    private
    def init_images
      i_left = Image.new('olaf_left.png')
      i_right = Image.new('olaf_right.png')
      i_standing = Image.new('olaf_standing.png')

      @image = ImageBank.new(self)

      @image.add_pair('standing_', i_standing)
      @image.add_pair('standing_left', i_left)
      @image.add_pair('standing_right', i_right)
      @image.add_pair('moving_left', i_left)
      @image.add_pair('moving_right', i_right)
      @image.add_pair('stucked_left', i_left)
      @image.add_pair('stucked_right', i_right)
      @image.add_pair('falling_', i_standing)
      @image.add_pair('falling_left', i_left)
      @image.add_pair('falling_right', i_right)
      @image.add_pair('dead', Image.new('dead.png'))
    end

  end # class
end # module
