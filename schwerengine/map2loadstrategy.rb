# map2loadstrategy.rb
# igneus 3.10.2008

module SchwerEngine

  # Abstract superclass of loader classes for Map2.
  # In subclasses it should be enough to extend the constructor -
  # add some logic to fill instance variables used in load_* methods.

  class Map2LoadStrategy

    def initialize(source)
      @source = source

      if @source.respond_to? :path then
        @dir = File.dirname @source.path
      else
        @dir = "."
      end

      @log = Log4r::Logger['location loading log']

      @background = nil
      @foreground = nil

      @blocks = []

      @tile_width = 0
      @tile_height = 0
    end

    def load_setup(map)
      map.tile_width = @tile_width
      map.tile_height = @tile_height
    end

    def load_blocks(map)
      @blocks.each {|l| 
        map.blocks.push l 
      }
    end

    def load_surfaces(map)
      map.background = @background
      map.foreground = @foreground
    end
  end
end
