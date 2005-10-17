# shooting.rb
# igneus 17.10.2005

=begin
= NAME
Shooting

= DESCRIPTION
Mixin which provides some useful methods for objects which shoot.
You can subclass (({Shooter})) to get the same effect.
=end

module FreeVikings

  module Shooting

=begin
= Constants

--- Shooting::SHOT_CLASS
Class of shots the (({Shooting})) shoots.
It should have the same public interface as (({Shot})).
=end

    SHOT_CLASS = nil

=begin
--- Shooting::SHOT_VELOCITY
Velocity (in pixels per second) of shots.
=end

    SHOT_VELOCITY = 85

=begin
= Instance methods

--- Shooting#firing?
Says if the (({Shooting})) was active now (some (({Shooting}))s can be switched
off, then ((<Shooting#firing?>)) returns ((|false|))).
=end

    def firing?
      @firing
    end

    private

=begin
= Private instance methods

--- Shooting#shoot
This method is called whenever the (({Shooting})) decides to shoot.
Normally it releases the shot.
It can be redefined to change the behaviour.
=end

    def shoot
      if @firing then
        @location.add_sprite(self.class::SHOT_CLASS.new([left, top+10], self.class::SHOT_VELOCITY))
      end
    end
  end # module Shooting
end # module FreeVikings
