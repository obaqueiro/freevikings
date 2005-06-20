# activeobject.rb
# igneus 16.6.2005

=begin
= ActiveObject
ActiveObject is an object which doesn't need to be updated regularly like
sprites. It's only updated when a key is pressed over it or if it's stroken
by some gun.
=end

module FreeVikings

  class ActiveObject

    def initialize(position)
      @rect = Rectangle.new(position[0], 
                            position[1], 
                            position[2] ? position[2] : 0, 
                            position[3] ? position[3] : 0)
    end

    attr_reader :rect

    def activate
    end

    def deactivate
    end

    def hurt
    end
  end # class ActiveObject
end # module FreeVikings
