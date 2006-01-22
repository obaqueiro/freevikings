# penguin.rb
# igneus 22.10.2005

require 'transportable.rb'
require 'monster.rb'
require 'sophisticatedspritestate.rb'
require 'sophisticatedspritemixins.rb'
require 'monstermixins.rb'

module FreeVikings

  class Penguin < Sprite

    include Monster
    include SophisticatedSpriteMixins::Walking
    include MonsterMixins::ShieldSensitive

    WIDTH = 37
    HEIGHT = 54

    BASE_VELOCITY = 70

    def initialize(position)
      super(position)
      @state = SophisticatedSpriteState.new
      @energy = 3
    end

    def update
      update_transport
      update_movement_state
      update_position
    end

    def state
      @state.direction
    end

    def init_images
      l_imgs = []
      1.upto(3) {|i| l_imgs.push Image.load("penguin_left_#{i}.tga")}
      r_imgs = []
      1.upto(3) {|i| r_imgs.push Image.load("penguin_right_#{i}.tga")}

      i_left = Animation.new(0.3, l_imgs)
      i_right = Animation.new(0.3, r_imgs)

      @image = Model.new({'left' => i_left, 'right' => i_right})
    end

    private

    def update_transport
      transport_length = case @state.direction
                         when 'right'
                           20
                         when 'left'
                           -20
                         end

      @location.sprites_on_rect(self.rect).each do |s|
        if s.kind_of? Transportable then
          s.start_transport self

          s.transport_move transport_length, 0, self
          s.end_transport self
        end
      end
    end

    def update_movement_state
      # stop if there is a Shield
      serve_shield_collision {@state.move_back}

      # turn back if there is a wall or something solid
      unless location.area_free?(Rectangle.new(next_left, @rect.top,
                                               @rect.w, @rect.h))
        @state.move_back
      end
    end

    def update_position
      @rect.left = next_left
    end
  end # class Penguin
end # module FreeVikings
