# team.rb
# igneus 1.2.2005

require 'forwardable'

module FreeVikings

  # Our vikings are one company and one of them without the others can't do
  # anything. So if they want to finish a level, they have to reach 
  # an EXIT point all at once.
  #
  # A Team object is a way to group them and to work with them together.
  # Apart of the other useful features it helps to say if all the vikings are 
  # on the EXIT point mentioned above.
  #
  # In the past it was designed as a pretty general class, but in freeVikings
  # I use just one team - team of vikings - and so I have changed it
  # to provide some special services when working with the vikings.

  class Team < Group

    extend Forwardable

    # Builds a new Team of the Vikings (or, theoretically, any other 
    # Sprites) given as arguments. A number of arguments isn't limited,
    # but in the freeVikings game only three-member Team is used.

    def initialize(*members)
      @members = members
      @active = 0 # index aktivniho clena tymu
    end

    # accepts viking's name ('erik', 'Erik', 'ERIK') or class (Warior)
    # and returns corresponding viking.
    # If a Number is given, returns team member on that index.

    def [](id)
      if id.kind_of? Number then
        return @members[index]
      end

      if id.kind_of? Class then
        return @members.find {|m| m.kind_of? id}
      end

      if id.kind_of? String then
        case id
        when /[Ee][Rr][Ii][Kk]/
          return self[Sprinter]
        when /[Bb][Aa][Ll][Ee][Oo][Gg]/
          return self[Warior]
        when /[Oo][Ll][Aa][Ff]/
          return self[Shielder]
        else
          raise ArgumentError, "Unknown viking name '#{id}'"
        end
      end

      raise ArgumentError, "Only Number, Class and String values are accepted (not '#{id.class}')"
    end

    # Returns the active member of the Team. (During the game it's that one
    # you can control by the keyboard at the time.)
    # After Team initialization the first added member is made active.

    def active
      @members[@active]
    end

    def active=(member)
      if member?(member) and member.alive? then
        @active = @members.index member
      end
    end

    # Sets the next living member of the Team active. Throws 
    # Team::NotATeamMemberAliveException if there is no member alive 
    # to make active.

    def next(recursive_grade = 0)
      raise NotATeamMemberAliveException.new("No member of the team is alive.") if recursive_grade > @members.size
      @active = (@active + 1) % @members.size
      self.next(recursive_grade + 1) unless active.alive?
      return self.active
    end

    # Sets the member before the active one active. Throws 
    # Team::NotATeamMemberAliveException if there is no member alive 
    # to make active.

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

    def_delegator :@members, :each
    def_delegator :@members, :each_with_index

    # Iterator. Yields every living Team member into a given block.

    def each_alive
      @members.each {|m| yield m if m.alive?}
    end

    # Answers by a boolean value a question: 'Is there any Team member alive?'

    def alive?
      return true if alive_size > 0
      return false
    end

    # A count of members.

    def size
      @members.size
    end

    # A count of members alive.

    def alive_size
      @members.find_all {|m| m.alive?}.size
    end

    # Returns true if anybody is a Team member, false otherwise.

    def member?(anybody)
      @members.member? anybody
    end

    # An exception class thrown by Team#next and Team#previous
    # if there is no Team member to be made active.

    class NotATeamMemberAliveException < RuntimeError
    end # class NotATeamMemberAliveException
  end # class Team
end # module FreeVikings
