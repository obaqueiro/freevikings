# deadviking.rb
# igneus 4.3.2005

# Trida reprezentujici zesnuleho vikinga.

require 'sprite'

module FreeVikings

  class DeadViking < Sprite

    STATE_DURATION = 1.1
    LAST_STATE = 2

    HEIGHT = 100
    WIDTH = 80

    def initialize(position)
      super(position)
      @rect = Rectangle.new(position[0], position[1], WIDTH, HEIGHT)
      @image = ImageBank.new(self)
      im1 = Image.new('dead.png')
      im2 = Image.new('dead2.png')
      im3 = Image.new('dead3.png')
      @image.add_pair '0', im1
      @image.add_pair '1', im2
      @image.add_pair '2', im3
      @image.add_pair '3', im3

      @state = 0
      @last_update_time = Time.now.to_i
    end

    def state
      @state.to_s
    end

    def update
      # Jednou za kratky cas se zmeni stav a mozna i obrazek. Az dojdeme
      # k poslednimu stavu, mrtvola zmizi.
      if ((now = Time.now.to_i) - @last_update_time) > STATE_DURATION
	@state += 1
	@last_update_time = now
      end
      # Jestli uz mrtvola strasila dost dlouho, zmizi:
      if @state > LAST_STATE then
	@location.delete_sprite self
      end
    end
  end # class DeadViking
end # module FreeVikings
