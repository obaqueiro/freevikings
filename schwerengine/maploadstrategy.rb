# maploadstrategy.rb
# igneus 29.1.2005

=begin
= NAME
MapLoadStrategy

= DESCRIPTION
(({MapLoadStrategy})) is an abstract superclass of classes which are 
used to load map contents from different kinds of sources and source
formats.

= Superclass
Object
=end

module SchwerEngine

  class MapLoadStrategy

=begin
--- MapLoadStrategy#max_width
--- MapLoadStrategy#max_height
=end

    attr_reader :max_width
    attr_reader :max_height

    def initialize(source)
      @source = source

      if @source.respond_to? :path then
        @dir = File.dirname @source.path
      else
        @dir = "."
      end

      @log = Log4r::Logger['location loading log']
    end

    def load(blocks_matrix)
    end

    def load_map(blocks_matrix)
      load(blocks_matrix)
    end
  end # class MapLoadStrategy
end # module
