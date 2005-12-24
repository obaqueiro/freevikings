# monstermixins.rb
# igneus 29.6.2005

=begin
= MonsterMixins
Mixin modules from namespace ((<MonsterMixins>)) contain methods which
can be useful for programming different types of monsters.
=end

module FreeVikings

  module MonsterMixins

=begin
== HeroBashing

--- HeroBashing#bash_heroes
Finds all the colliding Heroes and hurts them.
If the instance variable ((|@angry|)) is true, hurts every Hero twice.
Class variable ((|@@bash_delay|)) must contain a number which means a delay 
between two strikes in seconds. (It's because on the quicker computers
((<HeroBashing>)) monsters would be quicker killers than on the slower ones.)
=end

    module HeroBashing

      @@bash_delay = 3

      def bash_heroes
        @bash_delay = @@bash_delay unless defined? @bash_delay
        @last_bash = 0 unless @last_bash

        return unless ready_to_attack?

        @location.heroes_on_rect(@rect).each {|s|
            s.hurt
            s.hurt if @angry # attacks twice per round if angry
            @last_bash = @location.ticker.now
        }
      end

      def ready_to_attack?
        @location.ticker.now >= (@last_bash + @bash_delay)
      end
    end # module HeroBashing

=begin
== ShieldSensitive
Mixin for (({Monster}))s which need to react onto a collision 
with a (({Shield})). (Typical reaction is to stop or to turn and escape.)
To be a ((<ShieldSensitive>)) a (({Monster})) must be a sort 
of a SophisticatedSprite. (See documentation 
for (({SophisticatedSpriteState})) and (({SophisticatedSpriteMixins})).)
=end

    module ShieldSensitive

=begin
--- ShieldSensitive#stopped_by_shield?
Detects if the (({Monster})) collides with any (({Shield})).
=end

      def stopped_by_shield?
        if @location.sprites_on_rect(self.rect).find {|s| 
            s.kind_of? Shield
          } then
          return true
        end
        return false
      end

=begin
--- ShieldSensitive#serve_shield_collision
If the (({Monster})) collides ith a (({Shield})), it yields into a given block.
If there is no (({Shield})) and the (({Monster})) is standing, it gets up
and goes right.
=end

      def serve_shield_collision
        if stopped_by_shield? then
          yield
        elsif @state.standing? then
          @state.move_right
        end
      end
    end # module ShieldSensitive
  end # module MonsterMixins
end # module FreeVikings
