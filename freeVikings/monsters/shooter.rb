# shooter.rb
# igneus 10.10.2005

=begin
= NAME
Shooter

= DESCRIPTION
(({Shooter})) is a (({Sprite})) which at some circumstances shoots
releases another independent (({Sprite})) of some type, usually a (({Shot})).

= Superclass
Sprite
=end

require 'sprite.rb'

module FreeVikings

  class Shooter < Sprite

=begin
= Constants

=begin
--- Shooter::SHOT_CLASS
Class of shots the (({Shooter})) shoots.
It should have the same public interface as (({Shot})).
=end

    SHOT_CLASS = nil

=begin
--- Shooter::SHOT_VELOCITY
Velocity (in pixels per second) of shots.
=end

    SHOT_VELOCITY = 85

    def initialize(startpos)
      super(startpos)
      @firing = true
      @last_update = 0
    end

=begin
= Instance methods

--- Shooter#firing?
Says if the (({Shooter})) was active now (some (({Shooter}))s can be switched
off, then ((<Shooter#firing?>)) returns ((|false|))).
=end

    def firing?
      @firing
    end

    private

=begin
= Private instance methods

--- Shooter#shoot
This method is called whenever the (({Shooter})) decides to shoot.
Normally it releases the shot.
It can be redefined to change the behaviour.
=end

    def shoot
      if @firing then
        @location.add_sprite(self.class::SHOT_CLASS.new([left, top+10], self.class::SHOT_VELOCITY))
      end
    end
  end # class Shooter
end # module FreeVikings
