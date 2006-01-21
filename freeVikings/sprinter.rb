# sprinter.rb
# igneus 1.2.2005

# Trida na miru pro Erika. Sprinter umi rychle behat a skakat, hlavou
# muze rozbijet zdi.

module FreeVikings

  class Sprinter < Viking

    JUMP_HEIGHT = 1.3 * Viking::HEIGHT

    FAVOURITE_COLOUR = [180,0,0]

    def initialize(name, start_position)
      super(name, start_position)
      init_images
      @ability = SprinterAbility.new self
      @state.ability = @ability
      @jump_start_y = nil 
    end

    def space_func_on
      return if not on_some_surface?
      @ability.space_on
    end

    def space_func_off
      @ability.space_off
      @jump_start_y = nil
    end

    def jump
      @state.rise
      @jump_start_y = @rect.bottom unless @jump_start_y
    end

    alias_method :_update, :update

    def update
      _update
      if not @jump_start_y.nil?
        # Nasledujici podminka ma smysl pouze ve svete, kde osa y ma nulu 
        # nahore; v normalnim svete by bylo nutne prehodit
        # mensence a mensitele v rozdilu.
        if (@jump_start_y - @rect.bottom) >= JUMP_HEIGHT
          space_func_off
        end
      end
    end

    private
    def init_images
      i_left = Image.load('erik_left.png')
      i_right = Image.load('erik_right.png')

      @image = Model.new

      @image.add_pair('onground_standing_left', i_left)
      @image.add_pair('onground_standing_right', i_right)
      @image.add_pair('onground_moving_left', i_left)
      @image.add_pair('onground_moving_right', i_right)

      @image.add_pair('onground_knocked-out_left', Image.load('erik_ko_left.png'))
      @image.add_pair('onground_knocked-out_right', Image.load('erik_ko_right.png'))

      @image.add_pair('falling_standing_right', i_right)
      @image.add_pair('falling_standing_left', i_left)
      @image.add_pair('falling_moving_right', i_right)
      @image.add_pair('falling_moving_left', i_left)
      @image.add_pair('falling_jumping_left', i_left)
      @image.add_pair('falling_jumping_right', i_right)

      @image.add_pair('rising_jumping_left', i_left)
      @image.add_pair('rising_jumping_right', i_right)

      @image.add_pair('onground_jumping_left', i_left)
      @image.add_pair('onground_jumping_right', i_right)

      @portrait = Portrait.new 'erik_face.tga', 'erik_face_unactive.gif', 'dead_face.png'
    end
  end # class
end # module
