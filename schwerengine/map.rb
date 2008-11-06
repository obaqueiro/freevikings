# map.rb
# igneus 2.10.2008

module SchwerEngine

  # Class Map rewritten almost from scratch because of need for
  # * multiple layers, some of them may be in front of game objects
  #   (foreground layers)
  # * custom tile size

  class Map
    
    def initialize(loader)
      @blocks = [] # 2D Array; values are true (solid) or false (non-solid)
      @tile_width = nil
      @tile_height = nil
      @background = nil # painted before game objects
      @foreground = nil # painted after game objects (only if it exists)

      loader.load_setup(self)
      loader.load_blocks(self)
      loader.load_surfaces(self)
      lock

      @rect = Rectangle.new 0, 0, width, height
    end

    # 2-dimensional Array of Boolean (true means solid tile). 
    # Frozen as soon as it is loaded (in Map2#new)

    attr_reader :blocks

    attr_reader :tile_width
    attr_reader :tile_height

    # Returns tile size if tile width and height are the same; raises 
    # RuntimeError otherwise

    def tile_size
      if @tile_width == @tile_height then
        return @tile_width
      end

      raise "Tile width and height are different - use 'tile_width' and 'tile_height'!"
    end

    # width of the map in px

    def width
      @tile_width * @blocks[0].size
    end

    # height of the map in px

    def height
      @tile_height * @blocks.size
    end

    attr_reader :rect

    # == Methods for loaders

    # give tile sizes
    # These methods are blocked as soon as the map is loaded - don't call 
    # them (they are available only for map loaders)

    def tile_width=(w)
      locked_test
      @tile_width = w
    end

    def tile_height=(h)
      locked_test
      @tile_height = h
    end

    # give RUDL::Surfaces

    def background=(b)
      locked_test
      @background = b
    end

    def foreground=(f)
      locked_test
      @foreground = f
    end

    # == Methods for map's client (e.g. Location in freeVikings)

    def paint_background(surface, paint_rect)
      if @background == nil then
        return
      end

      surface.blit(@background, [0,0], (paint_rect.to_a))      
    end

    alias_method :paint, :paint_background

    # If map has no foreground, nothing is done.

    def paint_foreground(surface, paint_rect)
      if @foreground == nil then
        return
      end

      surface.blit(@foreground, [0,0], (paint_rect.to_a))
    end

    # Says if given Rectangle is free of solid tiles.

    def area_free?(rect)
      leftmost_i = (rect.left / @tile_width).floor
      rightmost_i = (rect.right / @tile_width).floor

      top_line = (rect.top / @tile_height).floor
      bottom_line = (rect.bottom / @tile_height).floor

      if leftmost_i < 0 then
        leftmost_i = 0
      end
      if rightmost_i > (@blocks.first.size - 1) then
        rightmost_i = @blocks.first.size - 1
      end
      if top_line < 0 then
        top_line = 0
      end
      if bottom_line > (@blocks.size - 1) then
        bottom_line = @blocks.size - 1
      end

      #print "["
      top_line.upto(bottom_line) do |line_i|
        leftmost_i.upto(rightmost_i) do |tile_i|
          #print "[#{tile_i}, #{line_i}]"
          if @blocks[line_i][tile_i] == true then
            return false
          end
        end
      end
      #puts "]"
      
      return true # solid tile hasn't been found yet, area is free
    end

    # Says if given point [x,y] is in a free area

    def point_free?(xy_ary)
      x, y = xy_ary

      if x < 0 || y < 0 || x > width || y > height then
        return false
      end

      row = (y/@tile_height)
      col = (x/@tile_width)

      # solid tile is true, free tile false => return negation of tile
      return ! @blocks[row][col]
    end

    # accepts a Rectangle or Array of two numbers (position of a point)
    # and returns Rectangle containing that point or Rectangle and
    # expanded as much as possible (but where more ways of expansion
    # are, just one is returned and it is not granted to be the way
    # of biggest area).
    # If point or Rectangle isn't free, empty Rectangle on given position
    # is returned.
    # !!! If a non-free Rectangle is given, empty rectangle is returned
    # regardless of any part of given Rectangle being free or not!

    def largest_free_rect(position)
      if position.is_a? Rectangle then
        if ! area_free?(position) then
          return Rectangle.new(position.left, position.top, 0, 0)
        end

        expanded = position
      else
        # position is Array [x,y]
        x,y = position

        if ! point_free?(position) then
          return Rectangle.new(x,y,0,0)
        end

        expanded = Rectangle.new(x,y,0,0)
      end

      right_border_column = expanded.right / @tile_width
      left_border_column = expanded.left / @tile_width
      top_border_row = expanded.top / @tile_height
      bottom_border_row = expanded.bottom / @tile_height

      # expand to the right:
      catch :jump do
        loop do
          top_border_row.upto(bottom_border_row) do |row|
            if @blocks[row][right_border_column+1] == true then
              throw :jump
            end
          end
          right_border_column += 1
        end
      end

      # expand to the left:
      catch :jump do      
        loop do
          top_border_row.upto(bottom_border_row) do |row|
            if @blocks[row][left_border_column-1] == true then
              throw :jump
            end
          end
          left_border_column -= 1
        end
      end

      # expand up:
      catch :jump do
        loop do
          left_border_column.upto(right_border_column) do |col|
            if @blocks[top_border_row-1][col] == true then
              throw :jump
            end
          end
          top_border_row -= 1
        end
      end

      # expand down:
      catch :jump do
        loop do
          left_border_column.upto(right_border_column) do |col|
            if @blocks[bottom_border_row+1][col] == true then
              throw :jump
            end
          end
          bottom_border_row += 1
        end
      end

      x = left_border_column * @tile_width
      y = top_border_row * @tile_height
      # I don't understand well why in following two lines
      # values of right and bottom border have to be incremented - it may be
      # a bug!
      w = ((right_border_column+1) * @tile_width) - x
      h = ((bottom_border_row+1) * @tile_height) - y

      return Rectangle.new(x,y,w,h)
    end

    private

    def lock
      @locked = true

      @blocks.each {|l| l.freeze}
      @blocks.freeze
    end

    def locked?
      defined?(@locked) && @locked == true
    end

    def locked_test
      if locked? then
        raise MapLockedException
      end
    end

    public

    # Raised if method from API for loader is called when loading is finished

    class MapLockedException < RuntimeError
    end
  end
end
