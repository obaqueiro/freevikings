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
      @image = ImageBank.new(self)
      @image.add_pair('standing', Image.new('olaf_standing.png'))
      @image.add_pair('moving_left', Image.new('olaf_left.png'))
      @image.add_pair('moving_right', Image.new('olaf_right.png'))
      @image.add_pair('stucked_left', Image.new('olaf_left.png'))
      @image.add_pair('stucked_right', Image.new('olaf_right.png'))
      @image.add_pair('falling', Image.new('olaf_standing.png'))
    end

  end # class
end # module
