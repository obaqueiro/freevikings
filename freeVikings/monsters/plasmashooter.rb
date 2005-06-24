# plasmashooter.rb
# igneus 27.2.2005

# Automaticky vystrelovac plazmovych strel

require 'monsters/redshot.rb'

module FreeVikings

  class PlasmaShooter < Sprite

    DELAY = 2
    SHOT_VELOCITY = 55

    def initialize(startpos, direction='left')
      super(startpos)
      @image = Image.new('spitter_1.tga')
      @firing = true
      @last_update = 0
    end

    def destroy
      @energy = 0
    end

    def hurt
      shoot
    end

    def on
      @firing = true
    end

    def off
      @firing = false
    end

    def firing?
      @firing
    end

    def update
      if @location.ticker.now > @last_update + DELAY then
	@last_update = @location.ticker.now
        shoot
      end
    end

    private

    def shoot
      if @firing then
        @location.add_sprite RedShot.new([left, top+10], Velocity.new(- SHOT_VELOCITY))
      end
    end
  end # class PlasmaShooter
end # module FreeVikings
