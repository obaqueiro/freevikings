# relativerect.rb
# igneus 17.11.2008

require 'weakref'

module SchwerEngine

  # RelativeRectangle has nearly the same interface as Rectangle
  # (doesn't support self-modifying methods), but differs a bit:
  # it is a Rectangle which is defined only in relation to another Rectangle -
  # it's position, width, height etc. are defined relativelly to the other's.
  # It has WeakRef of the "leader" Rectangle and fails to work
  # if the "leader" is garbage collected. (i.e. any method may raise
  # WeakRef::RefError - defined in weakref.rb in Ruby's standard library)

  class RelativeRectangle < Rectangle

    # Accepts "leader" Rectangle and four numeric values:
    # differences of position (x, y), width and height.

    def initialize(rect, d_x, d_y, d_w, d_h)
      @rect = WeakRef.new rect
      @d_x = d_x
      @d_y = d_y
      @d_w = d_w
      @d_h = d_h

      # against some forgotten inherited methods - they will raise error 
      # immediately when they try to access @array
      @array = nil 

      puts self.inspect
    end

    # Receives two Rectangles.
    # r1 is used as "leader" and produced RelativeRectangle is in the same
    # relation to r1 as r2 (i.e. has same position, width and height 
    # differences) at the time of creation.

    def RelativeRectangle.new2(r1, r2)
      return RelativeRectangle.new(r1, 
                                   r2.left - r1.left,
                                   r2.top - r1.top,
                                   r2.w - r1.w,
                                   r2.h - r1.h)
    end

    def at(i)
      case i
      when 0
        return @rect.left + @d_x
      when 1
        return @rect.top + @d_y
      when 2
        return @rect.w + @d_w
      when 3
        return @rect.h + @d_h
      else
        return nil
      end
    end

    alias_method :[], :at

    # hide some inherited methods:
    private :[]=, :left=, :top=, :w=, :h=, :bottom=, :right=, :expand!, :move!
  end
end
