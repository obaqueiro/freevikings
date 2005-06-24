# monstermixins.rb
# igneus 29.6.2005

=begin
= MonsterMixins
Mixin modules from namespace ((<MonsterMixins>)) contain methods which
can be useful for programming different types of monsters.
=end

require 'hero.rb'

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
        return if @location.ticker.now < (@last_bash or (@last_bash = @location.ticker.now)) + (@bash_delay or @@bash_delay)
        @location.sprites_on_rect(@rect).each {|s|
          if s.kind_of? Hero
            s.hurt
            s.hurt if @angry # nastvany robot ublizuje dvakrat za kolo
            @last_bash = @location.ticker.now
          end
        }
      end
    end # module HeroBashing
  end # module MonsterMixins
end # module FreeVikings
