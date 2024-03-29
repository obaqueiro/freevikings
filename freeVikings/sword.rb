# sword.rb
# igneus 22.2.2005

module FreeVikings

  # Baleog's sword

  class Sword < Sprite

    WIDTH = 47
    HEIGHT = 10

    def initialize(owner)
      super([0,0])
      @owner = owner
      @z = @owner.z+10
      @direction = 'right'
      @monsters_damaged = false
      init_images
    end

    def left
      @rect.left
    end

    def top
      @rect.top
    end

    def state
      @owner.state.direction
    end

    # This method must be called when a Sword is drawn from the sheath.
    # Don't confuse with methods for drawing onto the screen.
    # In the freeVikings code 'paint' identifier is used for methods which
    # paint and draw graphics.

    def draw
      @monsters_damaged = false
    end

    def update
      update_position
      clobber_monsters
    end

    private

    def update_position
      @rect.top = (@owner.rect.top + @owner.rect.h / 2.2).to_i
      @rect.left = (case state
                   when 'left'
                     @owner.rect.left - self.rect.w + @owner.rect.w/5
                   when 'right'
                     @owner.rect.left + @owner.rect.w - @owner.rect.w/5
                   end).to_i
    end

    # The Sword damages monsters only once per use.
    # A 'use' is a time between it's drawn and hidden in the sheath again.
    # So you can't just say Baleog to stand with a sword in front of him.
    # On quicker computers this trick would kill armies of dragons in a
    # few milliseconds.

    def clobber_monsters
      unless @monsters_damaged
        stroken = @location.sprites_on_rect(self.rect)
        stroken.concat @location.active_objects_on_rect(self.rect)

        stroken.each do |s|
          if s.kind_of? Monster then
            begin
              s.hurt(self)
            rescue ArgumentError
              s.hurt
            end
            @monsters_damaged = true
          end
        end
        return true
      end
      return false
    end

    def init_images
      left = Image.load('sword_left.png')
      right = Image.load('sword_right.png')
      @image = Model.new
      @image.add_pair 'left', left
      @image.add_pair 'right', right
    end
  end # class Sword
end # module FreeVikings
