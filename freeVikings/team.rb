# team.rb
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

    def update
      each {|m| m.update}
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

    def each
      @members.each {|m| yield m}
    end

    # Metoda vracejici vsechny sprajty.
    # Slouzi k realisaci vzoru Skladba v zobrazovani sprajtu.
    # Nutno rici, ze nepredpokladame, ze soucasti Teamu bude
    # dalsi Team nebo jina Skladba. Jen proto each vyhovuje.

    alias_method :each_displayable, :each

  end # class

  class NotATeamMemberAliveException < RuntimeError
  end
end # module
