# deadviking.rb
# igneus 4.3.2005

# Trida reprezentujici zesnuleho vikinga.

require 'sprite'

module FreeVikings

  class DeadViking < Sprite

    STATE_DURATION = 4
    LAST_STATE = 2

    def initialize(position)
      super(position)
      @image = ImageBank.new(self)
      im = Image.new('dead.png')
      @image.add_pair '0', im
      @image.add_pair '1', im
      @image.add_pair '2', im

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
      end
      # Jestli uz mrtvola strasila dost dlouho, zmizi:
      if @state > LAST_STATE then
	@move_validator.delete_sprite self
      end
    end
  end # class DeadViking
end # module FreeVikings
