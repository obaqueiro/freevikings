# shielder.rb
# igneus 1.2.2005

# Trida na miru pro Olafa. Shielder ma stit, umi se jim branit a plachtit
# na nem.

module FreeVikings

  class Shielder < Viking

    def initialize(name, start_position)
      super(name, start_position)
      init_images
      @ability = ShielderAbility.new self
      @state.ability = @ability
      @shield = Shield.new self
    end

    def location=(location)
      @location = location
      @location.add_sprite @shield
      @shield.update
    end

    alias_method :_update, :update

    def shield_use
      return 'top' if @ability.shield_use == ShielderAbility::SHIELD_TOP
      return 'left' if @state.direction == 'left'
      return 'right'
    end

    def space_func_on
      @ability.space_on
    end

    alias_method :_velocity_vertic, :velocity_vertic

    SHIELD_GLIDE_ANTIACCELERATION = 0.5

    def velocity_vertic
      if @ability.shield_use == ShielderAbility::SHIELD_TOP
        return _velocity_vertic * SHIELD_GLIDE_ANTIACCELERATION
      end
      return _velocity_vertic
    end

    private
    def init_images
      i_left = Image.new('olaf_left.png')
      i_right = Image.new('olaf_right.png')
      i_standing = Image.new('olaf_standing.png')

      @image = ImageBank.new(self)

      @image.add_pair('onground_standing_left', i_left)
      @image.add_pair('onground_standing_right', i_right)
      @image.add_pair('onground_moving_left', i_left)
      @image.add_pair('onground_moving_right', i_right)
      @image.add_pair('falling_standing_right', i_right)
      @image.add_pair('falling_standing_left', i_left)
      @image.add_pair('falling_moving_right', i_right)
      @image.add_pair('falling_moving_left', i_left)
    end

  end # class Shielder

  class Shield < Sprite

    def initialize(shielder)
      @shielder = shielder
      @image = ImageBank.new(self, 
                             {'top' => Image.new('shield_top.png'),
                              'left' => Image.new('shield_left.png'),
                              'right' => Image.new('shield_right.png')}
                             )
      @rect = Rectangle.new 0,0,0,0
    end

    def update
      unless @shielder.alive?
        destroy
        return
      end
      @rect.left = case state
                     when 'top'
                       @shielder.left 
                     when 'left'
                       @shielder.left - 20 - 1
                     when 'right'
                       @shielder.rect.right + 1
                     end # case state
      @rect.top = case state
                     when 'top'
                       @shielder.top - 10 - 1
                     when 'left', 'right'
                       @shielder.top + 10
                     end # case state
      @rect.h = image.h
      @rect.w = image.w
    end # method update

    def state
      @shielder.shield_use
    end
  end # class Shield
end # module FreeVikings
