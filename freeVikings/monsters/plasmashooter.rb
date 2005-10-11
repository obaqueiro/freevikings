# plasmashooter.rb
# igneus 27.2.2005

=begin
= NAME
PlasmaShooter

= DESCRIPTION
A (({Shooter})) which periodically shoots a (({RedShot})).
It can be switched on/off (usually by a (({Switch})) connected with it in
a location script).

= Superclass
Shooter
=end

require 'monsters/shooter.rb'
require 'monsters/redshot.rb'

module FreeVikings

  class PlasmaShooter < Shooter

=begin
= Constants

--- Shooter::DELAY
Delay between two shots (in seconds)
=end

    DELAY = 4.5

    SHOT_CLASS = RedShot
    SHOT_VELOCITY = -85

=begin
= Instance methods

--- PlasmaShooter#on
Switches the (({PlasmaShooter})) on.
=end

    def on
      @firing = true
    end

=begin
--- PlasmaShooter#off
Switches the (({PlasmaShooter})) off.
=end

    def off
      @firing = false
    end

    def hurt
    end

    def update
      if @location.ticker.now > @last_update + DELAY then
	@last_update = @location.ticker.now
        shoot
      end
    end

    def init_images
      @image = Image.load('spitter_1.tga')
    end
  end # class PlasmaShooter
end # module FreeVikings
