# monstermixins.rb
# igneus 29.6.2005

module FreeVikings

  # Mixin modules from namespace MonsterMixins contain methods which
  # can be useful for programming different types of monsters.

  module MonsterMixins

    # Mixin for Monsters which want to periodically try to hit colliding
    # Heroes.
    #
    # How to use?
    # - include MonsterMixins::HeroBashing in your Monster Sprite
    # - if you want to set your custom delay between to strikes to Heroes,
    #   set instance variable @bash_delay (number of seconds)
    # - if you want your Monster to take Heroes two lifes at once,
    #   set instance variable @angry to true
    # - call method bash_heroes in update; it checks if a strike should be made
    #   and tries to hit some Hero

    module HeroBashing

      @@bash_delay = 3

      def bash_heroes
        @last_bash = 0 unless @last_bash

        return unless ready_to_attack?

        @location.heroes_on_rect(@rect).each {|s|
            s.hurt
            s.hurt if @angry # attacks twice per round if angry
            @last_bash = @location.ticker.now
        }
      end

      def ready_to_attack?
        if ! defined?(@last_bash) then
          @last_bash = @location.ticker.now - 2 * bash_delay
        end

        return @location.ticker.now >= (@last_bash + bash_delay)
      end

      # Returns delay between two strikes to colliding Heroes.
      # It's mainly for internal use inside the code of mixin.

      def bash_delay
        if defined? @bash_delay
          @bash_delay
        else
          @@bash_delay
        end
      end
    end # module HeroBashing

    # Mixin for Monsters which need to react onto a collision 
    # with a Shield. (Typical reaction is to stop or to turn and escape.)
    # To be a ShieldSensitive a Monster must be a sort 
    # of a SophisticatedSprite. (See documentation 
    # for SophisticatedSpriteState and SophisticatedSpriteMixins.)

    module ShieldSensitive

      # Detects if the Monster collides with any Shield.

      def stopped_by_shield?
        if @location.sprites_on_rect(self.rect).find {|s| 
            s.kind_of? Shield
          } then
          return true
        end
        return false
      end

      # If the Monster collides ith a Shield, it yields into a given block.
      # If there is no Shield and the Monster is standing, it gets up
      # and goes right.

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
