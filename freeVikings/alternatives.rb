# alternatives.rb
# igneus 23.6.2005

# The critical classes have been rewritten in C++ and they can be loaded 
# as Ruby modules, but not everyone needs them and the Windows users often
# haven't got a chance to compile them (they haven't got SWIG and a C++
# compiler). So here it is where we decide whether to use Ruby or C++
# implementation.

if FreeVikings::OPTIONS["extensions"] then

  require "ext/Rectangle"
  FreeVikings::Rectangle = FreeVikings::Extensions::Rectangle::Rectangle
  # add a missing method:
  class FreeVikings::Rectangle
    def to_a
      [left, top, width, height]
    end
  end

else

  require "rect.rb"

end
