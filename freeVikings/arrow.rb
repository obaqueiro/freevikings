# arrow.rb
# igneus 20.2.2005

# Trida zastupujici sip

module FreeVikings

  class Arrow < Sprite

    attr_writer :move_validator

    def initialize(start_pos, velocity)
      @images = ImageBank.new(self)
      @images.add_pair('left', Image.new('arrow_left.tga'))
      @images.add_pair('right', Image.new('arrow_right.tga'))
      @start_pos = start_pos
      @velocity = velocity
      @start_time = Time.now.to_f
    end

    def top
      @start_pos[1]
    end

    def left
      @start_pos[0] + @velocity.value * (Time.now.to_f - @start_time)
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
      end
    end
  end # class Arrow
end # module FreeVikings
