# exit.rb
# igneus 24.2.2005

require 'sprite.rb'

=begin
= Exit
((<Exit>)) is a special (({Sprite})) which denotes the EXIT point 
of the (({Location})). The goal of all the freeVikings game is to get the three
vikings out of several terrible places. They can escape the level only if they
all stand on the EXIT point.
=end

module FreeVikings

  class Exit < Sprite

    def initialize(position)
      super position
      @image = Image.load 'exit.tga'
    end

=begin
--- Exit#team_exited?(team)
Returns true if all the living members of the (({Team })) ((|team|)) stand
on the EXIT.
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
