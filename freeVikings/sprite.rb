# sprite.rb
# igneus 19.1.2004

# Tridy sprajtu pro hru FreeVikings

require 'RUDL'

require 'velocity.rb'
require 'imagebank.rb'
require 'rect.rb'

module FreeVikings

  class Sprite
    # Trida pohyblivych objektu (typicky postavicek)

    BASE_VELOCITY = 135

    attr_reader :moving
    attr_accessor :move_validator

    def initialize(initial_position=[])
      @image = Image.new('nobody.tga')

      unless initial_position.empty?
	@position = initial_position.dup
      else
	@position = [70,60]
      end

      @moving = nil
    end

    # Metoda, kterou ma vsechno, co je zobrazitelne nebo obaluje
    # zobrazitelne. (vzor Skladba!)

    def each_displayable
      yield self
    end

    # Vrati vzdalenost od vrsku

    def top
      @position[1]
    end

    # Vrati vzdalenost odleva

    def left
      @position[0]
    end

    def position
      [left, top]
    end

    def position=(pos)
      @position = pos.dup
    end

    def destroy
    end

    def hurt
      destroy # jednoduche organismy zraneni nepreziji
    end

    def image
      @image.image
    end

    # Vrati obdelnik, ktery sprite zabira v aktualni lokaci

    def rect
      Rectangle.new *[left, top, image.w, image.h]
    end

    def move_left
    end

    def move_right
    end

    def stop
      @moving = nil
    end

    def update
    end

  end # class

end # module
