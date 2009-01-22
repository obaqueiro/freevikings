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

  class RelativeRectangle # < Rectangle

    # Accepts "leader" Rectangle and four numeric values:
    # differences of position (x, y), width and height.

    def initialize(rect, d_x, d_y, d_w, d_h)
      @rect = rect #WeakRef.new rect
      @d_x = d_x
      @d_y = d_y
      @d_w = d_w
      @d_h = d_h
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

    def left
      return @rect.left + @d_x
    end

    def top
      return @rect.top + @d_y
    end

    def w
      return @rect.w + @d_w
    end

    def h
      return @rect.h + @d_h
    end

    def right
      left + w
    end

    def bottom
      top + h
    end

    def point_inside?(po)
      po[0] >= self.left && po[0] <= self.right &&
        po[1] >= self.top && po[1] <= self.bottom
    end

    def top_left
      [left, top]
    end

    def top_right
      [right, top]
    end

    def bottom_left
      [left, bottom]
    end

    def bottom_right
      [right, bottom]
    end

    # hide some inherited methods:
    #private :[]=, :left=, :top=, :w=, :h=, :bottom=, :right=, :expand!, :move!

  end
end
