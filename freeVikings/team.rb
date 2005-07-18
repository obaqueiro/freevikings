# team.rb
# igneus 1.2.2005

=begin
= Team

Our vikings are one company and one of them without the others can't do
anything. So if they want to finish a level, they have to reach an EXIT point 
all at once.

A ((<Team>)) object is a way to group them and to work with them together.
Apart of the other useful features it helps to say if all the vikings are 
on the EXIT point mentioned above.
=end

require 'group.rb'

module FreeVikings

  class Team < Group

=begin
--- Team.new(*members)
Builds a new ((<Team>)) of the (({Viking}))s (or, theoretically, any other 
(({Sprite}))s) given as arguments. A number of arguments isn't limited,
but in the freeVikings game only three-member ((<Team>)) is used.
=end

    def initialize(*members)
      @members = members
      @active = 0 # index aktivniho clena tymu
    end

=begin
--- Team#active
Returns the active member of the ((<Team>)). (During the game it's that one
you can control by the keyboard at the time.)
After ((<Team>)) initialization the first added member is made active.
=end

    def active
      @members[@active]
    end

    def active=(member)
      if member?(member) and member.alive? then
        @active = @members.index member
      end
    end

    def active_index=(index)
      @active = index if index < size
    end

=begin
--- Team#next
Sets the next living member of the ((<Team>)) active. Throws 
((<Team::NotATeamMemberAliveException>)) if there is no member alive 
to make active.
=end

    def next(recursive_grade = 0)
      raise NotATeamMemberAliveException.new("No member of the team is alive.") if recursive_grade > @members.size
      @active = (@active + 1) % @members.size
      self.next(recursive_grade + 1) unless active.alive?
      return self.active
    end

=begin
--- Team#last
Sets the member before the active one active. Throws 
((<Team::NotATeamMemberAliveException>)) if there is no member alive 
to make active.
=end

    def previous(recursive_grade = 0)
      raise NotATeamMemberAliveException.new("No member of the team is alive.") if recursive_grade > @members.size
      if @active > 0
	@active = (@active - 1)
      else
	@active = @members.size - 1
      end
      previous(recursive_grade + 1) unless active.alive?
      return self.active
    end

=begin
--- Team#each
Standard iterator. Yields every ((<Team>)) member into a given block.
=end

    def each
      @members.each {|m| yield m}
    end

=begin
--- Team#each_alive
Iterator. Yields every living ((<Team>)) member into a given block.
=end

    def each_alive
      @members.each {|m| yield m if m.alive?}
    end

=begin
--- Team#alive?
Answers by a boolean value a question: 'Is there any ((<Team>)) member alive?'
=end

    def alive?
      return true if alive_size > 0
      return false
    end

=begin
--- Team#size
A count of members.
=end

    def size
      @members.size
    end

=begin
--- Team#alive_size
A count of members alive.
=end

    def alive_size
      @members.find_all {|m| m.alive?}.size
    end

=begin
--- Team#member?(anybody)
Returns ((|true|)) if ((|anybody|)) is a ((<Team>)) member, ((|false|))
otherwise.
=end

    def member?(anybody)
      @members.member? anybody
    end

=begin
--- Team::NotATeamMemberAliveException
An exception class thrown by ((<Team#next>)) and ((<Team#previous>))
if there is no ((<Team>)) member to be made active.
=end

    class NotATeamMemberAliveException < RuntimeError
    end # class NotATeamMemberAliveException
  end # class Team
end # module FreeVikings
