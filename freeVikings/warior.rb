# warior.rb
# igneus 1.2.2005

# Podtrida tridy Viking vytvorena na miru Baleogovi.
# Valecnik umi mlatit kolem sebe mecem a strilet z luku.

require 'viking.rb'

module FreeVikings
  class Warior < Viking

    def initialize(name="")
      super name
      init_images
    end

    private
    def init_images
      @image = ImageBank.new(self)
      @image.add_pair('standing', Image.new('baleog_standing.png'))
      @image.add_pair('moving_left', Image.new('baleog_left.png'))
      @image.add_pair('moving_right', Image.new('baleog_right.png'))
      @image.add_pair('stucked_left', Image.new('baleog_left.png'))
      @image.add_pair('stucked_right', Image.new('baleog_right.png'))
      @image.add_pair('falling', Image.new('baleog_standing.png'))
    end

  end # class
end #module
