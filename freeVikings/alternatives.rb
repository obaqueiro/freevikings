# alternatives.rb
# igneus 23.6.2005

# The critical classes have been rewritten in C++ and they can be loaded 
# as Ruby modules, but not everyone needs them and the Windows users often
# haven't got a chance to compile them (they haven't got SWIG and a C++
# compiler). So here it is where we decide whether to use Ruby or C++
# implementation.

if FreeVikings::OPTIONS["extensions"] then

  require "ext/Extensions"

  # add some missing methods:


  class FreeVikings::Extensions::Rectangle
    def to_a
      [left, top, width, height]
    end

    def dup
      return self.class.new(self)
    end
  end
  FreeVikings::Rectangle = FreeVikings::Extensions::Rectangle

  class FreeVikings::Extensions::Map
    alias_method :old_init, :initialize
    def initialize
      old_init()

    end
  end
  #FreeVikings::Map = FreeVikings::Extensions::Map

else

  require "rect.rb"
  require "map.rb"

end
