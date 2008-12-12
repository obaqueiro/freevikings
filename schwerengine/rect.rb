# rect.rb
# igneus 22.2.2005

# Rectangle instance has information about a rectangular area
# of the game world.
# In December 2008 this implementation of Rectangle was replaced with
# a newer, optimized one.

module SchwerEngine
  module Old
    class Rectangle

      RECTANGLE_VERSION = 1

      def initialize(*coordinates)
        if coordinates.size >= 4 then
          @array = Array.new(coordinates[0..3])
        else
          @array = Array.new(coordinates[0][0..3])
        end
      end

      # Accepts two points (2-element Arrays), creates Rectangle 
      # which has them as corners

      def Rectangle.new_from_points(p1, p2)
        x1, y1 = p1
        x2, y2 = p2

        x = x1 < x2 ? x1 : x2
        y = y1 < y2 ? y1 : y2

        w = (x1 - x2).abs
        h = (y1 - y2).abs

        return Rectangle.new(x,y,w,h)
      end

      def ==(r2)
        r2.kind_of?(Rectangle) &&
          self.left == r2.left && self.top == r2.top &&
          self.w == r2.w && self.h == r2.h
      end

      # Returns new empty Rectangle

      def Rectangle.new_empty
        Rectangle.new(0,0,0,0)
      end

      # Takes values from another rect

      def copy_values(rect)
        self.left = rect.left
        self.top = rect.top
        self.w = rect.w
        self.h = rect.h

        return self
      end

      def collides?(rect)
        if self.left <= rect.right and
            rect.left <= self.right and
            self.top <= rect.bottom and
            rect.top <= self.bottom then
          return true
        end
        return false
      end

      def at(i)
        @array.at(i)
      end

      def [](i)
        @array[i]
      end

      def []=(i, v)
        @array[i] = v
      end

      def left
        at 0
      end

      def left=(i)
        self[0] = i
      end

      alias_method :x, :left
      alias_method(:x=, :left=)

      def top
        at 1
      end

      def top=(i)
        self[1] = i
      end

      alias_method :y, :top
      alias_method(:y=, :top=)

      def w
        at 2
      end

      def w=(i)
        self[2] = i
      end

      alias_method :width, :w
      alias_method(:width=, :w=)

      def h
        at 3
      end

      def h=(i)
        self[3] = i
      end

      alias_method :height, :h
      alias_method(:height=, :h=)

      def bottom
        top + h
      end

      def bottom=(b)
        if b < top then
          raise ArgumentError, "Bottom edge cannot be over top edge."
        end
        
        self.h = b - top
      end

      def right
        left + w
      end

      def right=(r)
        if r < left then
          raise ArgumentError, "Right edge cannot be on the left of left edge."
        end

        self.w = r - left
      end

      # Methods returning [x,y] coordinates of corners

      def top_left
        [self.left, self.top]
      end

      def top_right
        [self.right, self.top]
      end

      def bottom_left
        [self.left, self.bottom]
      end

      def bottom_right
        [self.right, self.bottom]
      end

      # Returns an expanded copy of itself.
      # The expansion is done so that the rectangle's center stays on place and
      # it's edges move.
      #
      # r = Rectangle.new(2,2,2,2) # => [2, 2, 2, 2]
      # r.expand(1,1)              # => [1, 1, 4, 4]

      def expand(expand_x=0, expand_y=0)
        Rectangle.new(left - expand_x, top - expand_y,
                      w + 2 * expand_x, h + 2 * expand_y)
      end

      # Expand itself.

      def expand!(expand_x=0, expand_y=0)
        self.left -= expand_x
        self.w += 2 * expand_x
        self.top -= expand_y
        self.h += 2 * expand_y

        return self
      end

      # Expands every rect's side given amount of pixels.

      def expand2(left, right, top, bottom)
        return Rectangle.new(self.left - left,
                             self.top - top,
                             self.w + left + right,
                             self.h + top + bottom)
      end

      def expand2!(left, right, top, bottom)
        self.left -= left
        self.top -= top
        self.w += left + right
        self.h += top + bottom

        return self
      end

      # Moves Rectangle; returns self
      # r = Rectangle.new(100,100,10,10) # => [100,100,10,10]
      # r.move!(50,-10) # => [150,90,10,10]

      def move!(d_x, d_y)
        self.left += d_x
        self.top += d_y

        return self
      end

      def move_x!(d_x)
        move!(d_x, 0)
      end

      def move_y!(d_y)
        move!(0, d_y)
      end

      # Returns area of the Rectangle
      # Rectangle.new(50,1000,2,2).area # => 4
      # (The example is for me, because I know I'll forget meaning of the word
      # 'area' soon)

      def area
        w*h
      end

      # Returns another Rectangle, which is a common part of self and rect.
      # If there is no common part, returns an empty rect

      def common(rect)
        if ! collides?(rect) then
          return Rectangle.new_empty
        end

        result = Rectangle.new_empty
        
        if rect.left < self.left then
          result.left = self.left
        else
          result.left = rect.left
        end
        if rect.top < self.top then
          result.top = self.top
        else
          result.top = rect.top
        end
        if rect.right < self.right then
          result.right = rect.right
        else
          result.right = self.right
        end
        if rect.bottom < self.bottom
          result.bottom = rect.bottom
        else
          result.bottom = self.bottom
        end

        return result
      end

      def empty?
        w == 0 or h == 0
      end

      def center
        [left+w/2, top+h/2]
      end

      def to_a
        Array.new self[0..3]
      end

      def to_s
        "#{left}, #{top}, #{w}, #{h}"
      end

      def inspect
        "#<#{self.class}:#{self.object_id} [#{left}, #{top}, #{w}, #{h}]>"
      end

      # Does self contain r?

      def contains?(r)
        left <= r.left && right >= r.right &&
          top <= r.top && bottom >= r.bottom
      end
    end # class Rectangle
  end
end # module FreeVikings
