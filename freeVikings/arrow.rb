# arrow.rb
# igneus 20.2.2005

# Trida zastupujici sip

module FreeVikings

  class Arrow < Sprite

    def initialize(start_pos, velocity)
      super start_pos
      @images = ImageBank.new(self)
      @images.add_pair('left', Image.new('arrow_left.tga'))
      @images.add_pair('right', Image.new('arrow_right.tga'))
      @velocity = velocity
      @start_time = Time.now.to_f
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

    def image
      @images.image
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
	if s.is_a? Monster
	  s.hurt
	  @move_validator.delete_sprite s
	  @move_validator.delete_sprite self
	end
      end
    end
  end # class Arrow
end # module FreeVikings
