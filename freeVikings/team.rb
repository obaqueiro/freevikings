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
      @active = 0 # aktivni clen tymu
    end

    def active
      @members[@active]
    end

    # jako aktivniho nastavi dalsiho clena.

    def next
      @active = (@active + 1) % @members.size
      return self.active
    end

    # jako aktivniho nastavi minuleho

    def last
      if @active > 0
	@active = (@active - 1)
      else
	@active = @members.size - 1
      end
      return self.active
    end

    def each
      @members.each {|m| yield m}
    end
  end # class
end # module
