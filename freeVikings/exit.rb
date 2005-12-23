# exit.rb
# igneus 24.2.2005

require 'staticobject.rb'

=begin
= NAME
Exit

= DESCRIPTION
((<Exit>)) is a special (({Entity})) which denotes the EXIT point 
of the (({Location})). The goal of the freeVikings game is to get the three
vikings out of several terrible places. They can escape the level only if they
all stand on the EXIT point.

= Superclass
Entity
=end

module FreeVikings

  class Exit < Entity

=begin
= Included mixins
StaticObject
=end

    include StaticObject

    def initialize(position)
      super position
      @image = Image.load 'exit.tga'
    end

=begin
--- Exit#location=(loc)
--- Exit#location
=end

    attr_accessor :location

=begin
--- Exit#team_exited?(team)
Returns true if all the living members of the (({Team })) ((|team|)) stand
on the EXIT.
(It is called from inside of the (({Game})) instance.)
=end

    def team_exited?(team)
      sprites_ex = @location.sprites_on_rect(self.rect)
      team_members_ex = sprites_ex.find_all {|s| team.member? s }

      if team_members_ex.size == team.alive_size then
        return true
      else
        return false
      end
    end
  end
end
