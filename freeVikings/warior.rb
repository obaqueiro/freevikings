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

    def d_func
      @state = BowStretchingVikingState.new(self, @state)
    end

    private
    def init_images
      i_left = Image.new('baleog_left.png')
      i_right = Image.new('baleog_right.png')
      i_standing = Image.new('baleog_standing.png')

      @image = ImageBank.new(self)

      @image.add_pair('standing_', Image.new('baleog_standing.png'))
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
      @image.add_pair('bow_stretching_left', Image.new('baleog_shooting_left.png'))
      @image.add_pair('bow_stretching_right', Image.new('baleog_shooting_right.png'))
    end

  end # class Warior
end #module
