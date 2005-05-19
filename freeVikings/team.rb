# freeVikings - the "Lost Vikings" clone
# Copyright (C) 2005 Jakub "igneus" Pavlik

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# igneus 1.2.2005

# Vikingove jsou jedna parta a jeden bez druheho se do dalsiho levelu 
# nedostane.
# Trida Team slouzi k praci s celou skupinkou.

module FreeVikings

  class Team

    def initialize(*members)
      @members = []
      members.each {|m| @members.push m if m.is_a? Sprite}
      @active = 0 # index aktivniho clena tymu
    end

    def active
      @members[@active]
    end

    # jako aktivniho nastavi dalsiho clena.

    def next(recursive_grade = 0)
      raise NotATeamMemberAliveException.new("No member of the team is alive.") if recursive_grade > @members.size
      @active = (@active + 1) % @members.size
      self.next(recursive_grade += 1) unless active.alive?
      return self.active
    end

    # jako aktivniho nastavi minuleho

    def last(recursive_grade = 0)
      raise NotATeamMemberAliveException.new("No member of the team is alive.") if recursive_grade > @members.size
      if @active > 0
	@active = (@active - 1)
      else
	@active = @members.size - 1
      end
      last(recursive_grade + 1) unless active.alive?
      return self.active
    end

    def update
      each {|m| m.update}
    end

    def each
      @members.each {|m| yield m}
    end

    def each_alive
      @members.each {|m| yield m if m.alive?}
    end

    def alive?
      return true if alive_size > 0
      return nil
    end

    def size
      @members.size
    end

    def alive_size
      @members.find_all {|m| m.alive?}.size
    end

    def member?(anybody)
      @members.member? anybody
    end

  end # class


  class NotATeamMemberAliveException < RuntimeError
  end
end # module
