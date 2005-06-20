# shot.rb
# igneus 26.2.2005

# Trida Shot (strela) je supertridou pro vsechny primocare hubici sprajty.

require 'sprite.rb'

module FreeVikings

  class Shot < Sprite

    def initialize(start_pos, velocity)
      super(start_pos)
      if velocity.is_a? Numeric
        @velocity = Velocity.new velocity
      else
        @velocity = velocity
      end
      @start_time = Time.now.to_f
      @hunted_type = Sprite
    end

    attr_reader :hunted_type

    def destroy
      @velocity = Velocity.new
      @energy = 0
      @location.delete_sprite self
    end

    def state
      return "right" if @velocity.value > 0
      return "left"
    end

    def update
      @rect.left += @velocity.value * (Time.now.to_f - @start_time)

      unless @location.is_position_valid?(self, [left, top])
        destroy
	return
      end

      stroken = @location.sprites_on_rect(self.rect)
      stroken.concat @location.active_objects_on_rect(self.rect)
      while not stroken.empty? do
	s = stroken.pop
	if s.is_a? @hunted_type
	  s.hurt
          destroy
          return
	end
      end
    end

  end # class Shot
end # module FreeVikings
