# shot.rb
# igneus 26.2.2005

# Trida Shot (strela) je supertridou pro vsechny primocare hubici sprajty.

require 'sprite.rb'

module FreeVikings

  class Shot < Sprite

    def initialize(start_pos, velocity)
      super(start_pos)
      @velocity = velocity
      @start_time = Time.now.to_f
      @hunted_type = Sprite
    end

    def left
      @position[0] + @velocity.value * (Time.now.to_f - @start_time)
    end

    def destroy
      @velocity = Velocity.new
    end

    def state
      return "right" if @velocity.value > 0
      return "left"
    end

    def update
      unless @move_validator.is_position_valid?(self, [left, top])
	@move_validator.delete_sprite self
	return
      end

      stroken = @move_validator.sprites_on_rect(self.rect)
      stroken.delete self
      unless stroken.empty?
	s = stroken.pop
	if s.is_a? @hunted_type
	  s.hurt
	  @move_validator.delete_sprite self
	end
      end
    end

  end # class Shot
end # module FreeVikings
