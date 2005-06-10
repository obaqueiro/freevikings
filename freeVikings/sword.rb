# sword.rb
# igneus 22.2.2005

# Trida representujici kratky vikinsky mec

module FreeVikings

  class Sword < Sprite

    WIDTH = 47
    HEIGHT = 10

    def initialize(owner)
      @owner = owner
      @direction = 'right'
      @rect = Rectangle.new 0,0,WIDTH, HEIGHT
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

    def update
      @rect.w = image.w
      @rect.h = image.h

      @rect.top = (@owner.top + @owner.rect.h / 2.2).to_i

      @rect.left = (case @owner.state.direction
                   when 'left'
                     @owner.left - self.rect.w + @owner.rect.w/5
                   when 'right'
                     @owner.left + @owner.rect.w - @owner.rect.w/5
                   end).to_i

      stroken = @location.sprites_on_rect(self.rect)
      stroken.delete_if {|s| s == self or not s.is_a? Monster}
      stroken.each do |s|
        s.hurt
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
