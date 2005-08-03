# structuredworld.rb
# igneus 1.8.2005

=begin
= StructuredWorld
((<StructuredWorld>)) is a (({World})) which works with (({LevelSuite}))s.
=end

require 'world.rb'
require 'levelsuite.rb'

module FreeVikings

  class StructuredWorld < World

=begin
--- StructuredWorld(campaign_dir)
Argument ((|campaign_dir|)) is a name of the root directory 
of the (({LevelSuite})) hierarchy. It's also called 'a campaign directory',
because it contains a complete set of levels, which is also called 
'a campaign'.

(If you wanted, you wouldn't have to give a real 'campaign directory' 
as argument, it is possible to give a directory of any nested (({LevelSuite})),
but it isn't very usual.)
=end

    def initialize(campaign_dir)
      @levelsuite = LevelSuite.new(campaign_dir)
      next_location
    end

    def next_location
      @level = @levelsuite.next_level

      if @level == nil then
        @location = nil
        return nil
      end

      return create_location
    end

    def rewind_location
      return create_location
    end

    private

    def create_location
      @location = Location.new(@level.loader, @level.gfx_theme)
    end
  end # class StructuredWorld
end # module FreeVikings
