# sword.rb
# igneus 22.2.2005

# Trida representujici kratky vikinsky mec

module FreeVikings

  class Sword < Sprite

    # position is an two-element array,
    # direction is 'right' or 'left'

    def initialize
      super([0,0])
      init_images
      @direction = 'right'
      @position = [0,0]
    end

    def set(position, direction)
      @position = position
      @direction = direction
    end

    def left
      @position[0]
    end

    def top
      @position[1]
    end

    def state
      @direction
    end

    def update
      stroken = @move_validator.sprites_on_rect(self.rect)
      stroken.delete self
      unless stroken.empty?
	s = stroken.pop
	if s.is_a? Monster
	  s.hurt
	  @move_validator.delete_sprite s
	end
      end
    end

    private
    def init_images
      left = Image.new('sword_left.png')
      right = Image.new('sword_right.png')
      @image = ImageBank.new self
      @image.add_pair 'left', left
      @image.add_pair 'right', right
    end
  end # class Sword
end # module FreeVikings
