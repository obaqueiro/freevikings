# plasmashooter.rb
# igneus 27.2.2005

# Automaticky vystrelovac plazmovych strel

require 'redshot.rb'

module FreeVikings

  class PlasmaShooter < Sprite

    DELAY = 7

    def initialize(startpos, direction='left')
      super(startpos)
      @image = Image.new('spitter_1.tga')
      @last_update = Time.now.to_f
    end

    def destroy
      nil
    end

    def update
      if Time.now.to_f > @last_update + DELAY then
	@last_update = Time.now.to_f
	@move_validator.add_sprite RedShot.new([left, top+10], Velocity.new(-55))
      end
    end
  end # class PlasmaShooter
end # module FreeVikings
