# shooter.rb
# igneus 10.10.2005

require 'shooting.rb'

=begin
= NAME
Shooter

= DESCRIPTION
(({Shooter})) is a (({Sprite})) which at some circumstances shoots
releases another independent (({Sprite})) of some type, usually a (({Shot})).

= Superclass
Sprite
=end

module FreeVikings

  class Shooter < Sprite

=begin
= Included modules
Shooting
=end

    include Shooting

    def initialize(startpos)
      super(startpos)
      @firing = true
      @last_update = 0
    end
  end # class Shooter
end # module FreeVikings
