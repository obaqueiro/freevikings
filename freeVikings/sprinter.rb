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

    private
    def init_images
      @image = ImageBank.new(self)
      @image.add_pair('standing', Image.new('erik_standing.png'))
      @image.add_pair('moving_left', Image.new('erik_left.png'))
      @image.add_pair('moving_right', Image.new('erik_right.png'))
      @image.add_pair('stucked_left', Image.new('erik_left.png'))
      @image.add_pair('stucked_right', Image.new('erik_right.png'))
      @image.add_pair('falling', Image.new('erik_standing.png'))
      @image.add_pair('dead', Image.new('dead.png'))
    end
  end # class
end # module
