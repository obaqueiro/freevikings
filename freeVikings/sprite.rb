# sprite.rb
# igneus 19.1.2004

# Tridy sprajtu pro hru FreeVikings

require 'RUDL'

require 'velocity.rb'
require 'imagebank.rb'

module FreeVikings

  class Sprite
    # Trida pohyblivych objektu (typicky postavicek)

    BASE_VELOCITY = 135

    attr_reader :moving
    attr_writer :move_validator

    def initialize(initial_position=[])
      @image = Image.new('nobody.tga')

      unless initial_position.empty?
	@top = initial_position[1]
	@left = initial_position[0]
      else
	@top = 60
	@left = 70
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
      @top
    end

    # Vrati vzdalenost odleva

    def left
      @left
    end

    def destroy
    end

    def image
      @image.image
    end

    # Vrati obdelnik, ktery sprite zabira v aktualni lokaci

    def rect
      [left, top, left + image.w, top + image.h]
    end

    def move_left
    end

    def move_right
    end

    def stop
      @moving = nil
    end

  end # class

end # module
