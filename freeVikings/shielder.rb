# shielder.rb
# igneus 1.2.2005

# Trida na miru pro Olafa. Shielder ma stit, umi se jim branit a plachtit
# na nem.

require 'shield.rb'

module FreeVikings

  class Shielder < Viking

    FAVOURITE_COLOUR = [190, 190, 0]

    def initialize(name, start_position)
      super(name, start_position)
      init_images
      @ability = ShielderAbility.new self
      @state.ability = @ability
      @shield = Shield.new self

      Viking.shield = @shield # reference to the shield for all vikings
    end

    def location=(location)
      @location = location
      @location.add_sprite @shield
      @shield.update
    end

    alias_method :_update, :update

    def destroy
      Viking.shield = nil # remove the shield reference (shield disappeared)
      super
    end

    def update
      _update
      @shield.unofficial_update
    end

    def shield_use
      return 'top' if @ability.shield_use == ShielderAbility::SHIELD_TOP
      return 'left' if @state.direction == 'left'
      return 'right'
    end

    def space_func_on
      @ability.space_on

      if shield_use != 'top' then
        @start_fall = @rect.top
      end
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
      # i_left = Image.load('olaf_left.png')
      # i_right = Image.load('olaf_right.png')

      i_left1 = Image.load('vikings/olaf/olaf_walk2_left.tga')
      i_right1 = Image.load('vikings/olaf/olaf_walk2_right.tga')

      i_right_breath = Image.load('vikings/olaf/olaf_breath_right.tga')
      i_left_breath = Image.load('vikings/olaf/olaf_breath_left.tga')

      i_left = Animation.new(0.4,
                             [i_left1,
                              Image.load('vikings/olaf/olaf_walk1_left.tga')])

      i_right = Animation.new(0.4,
                              [i_right1,
                               Image.load('vikings/olaf/olaf_walk1_right.tga')])

      i_stand_left = Animation.new(1,
                                   [i_left1, i_left_breath])

      i_stand_right = Animation.new(1,
                                   [i_right1, i_right_breath])


      @image = Model.new(self)

      @image.add_pair('onground_standing_left', i_stand_left)
      @image.add_pair('onground_standing_right', i_stand_right)
      @image.add_pair('onground_moving_left', i_left)
      @image.add_pair('onground_moving_right', i_right)

      @image.add_pair('onground_knocked-out_left', 
                      Image.load('olaf_ko_left.png'))
      @image.add_pair('onground_knocked-out_right', 
                      Image.load('olaf_ko_right.png'))

      @image.add_pair('falling_standing_right', i_right1)
      @image.add_pair('falling_standing_left', i_left1)
      @image.add_pair('falling_moving_right', i_right1)
      @image.add_pair('falling_moving_left', i_left1)

      @portrait = Portrait.new 'olaf_face.tga', 'olaf_face_unactive.gif', 'dead_face.png'
    end

  end # class Shielder

end # module FreeVikings
