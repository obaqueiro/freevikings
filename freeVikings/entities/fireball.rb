# fireball.rb
# igneus 29.1.2009

require 'monstermixins.rb'

module FreeVikings

  class FireBall < Sprite

    include MonsterMixins::ShieldSensitive

    SPEED = 350
    WIDTH = HEIGHT = 32

    # direction is :left or :right

    def initialize(position, direction=:right)
      @direction = direction
      @dir_i = @direction == :right ? 1 : -1
      super(position)
    end

    def update
      @rect.left += @location.ticker.delta * SPEED * @dir_i

      if stopped_by_shield? then
        destroy
        return
      end

      unless @location.area_free?(@rect)
        destroy
        return
      end

      @location.heroes_on_rect(@rect) do |h|
        h.hurt
        destroy
        return
      end
    end

    def init_images
      frame_names = ['1', '2', '3']
      spritesheet = SpriteSheet.load2('fireball.png', 32, 32, frame_names)
      frames = if @direction == :left then
                 frame_names.collect {|n| spritesheet[n].mirror_x }
               else
                 frame_names.collect {|n| spritesheet[n] }
               end
      @image = Animation.new(0.2, frames)
    end
  end
end
