# shot.rb
# igneus 26.2.2005

=begin
= NAME
Shot

= DESCRIPTION
(({Shot})) is anything that flies left or right until it crashes into a wall
or some (({Sprite})) of type((|@hunted_type|)) ((({Sprite})) by default).
=end

module FreeVikings

  class Shot < Sprite

    def initialize(start_pos, velocity)
      @velocity = velocity
      @hunted_type = Sprite
      @energy = 1
      super(start_pos)
    end

    attr_accessor :hunted_type

    def destroy
      @velocity = 0
      @energy = 0
      @location.delete_sprite self
    end

    def state
      return "right" if @velocity > 0
      return "left"
    end

    def update
      @rect.left += @velocity * @location.ticker.delta

      unless @location.area_free? @rect
        destroy
	return
      end

      stroken = @location.sprites_on_rect(self.rect)
      stroken.concat @location.active_objects_on_rect(self.rect)
      while not stroken.empty? do
	s = stroken.pop
	if s.kind_of? @hunted_type
          begin
            s.hurt(self)
          rescue ArgumentError
            s.hurt
          end
          destroy
          return
	end
      end
    end

  end # class Shot
end # module FreeVikings
