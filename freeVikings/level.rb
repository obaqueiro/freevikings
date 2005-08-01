# level.rb
# igneus 1.8.2005

=begin
= Level
((<Level>)) is a subclass of (({LevelSuite})). It provides the same interface
plus method ((<Level#loader>)) which returns 
the (({LocationLoadStrategy})) to load the ((<Level>)) data into the
(({Location})) instance.
So don't confuse ((<Level>)) and (({Location}))!
((<Level>)) is a minimalistic object which contains only a few information
needed to load the level data. (({Location})) is a huge heap of objects
which play their roles in the game.
=end

require 'levelsuite.rb'
require 'xmllocationloadstrategy.rb'

module FreeVikings

  class Level < LevelSuite

=begin
--- Level.new(dirname)
Argument ((|dirname|)) is a name of the directory where all the data for
the ((<Level>)) are. There should be one XML file in the directory -
the file with the (({Location})) definition. Optionally there can be some
scripts (with .rb extension).
=end

    def initialize(dirname)
      @dirname = dirname
      @members = []
      @active_member = self
    end

=begin
--- Level#loader
Returns a (({LocationLoadStrategy})) instance which is able to load 
the data from the ((|@dirname|)) directory into the (({Location})) object.
=end

    def loader
      XMLLocationLoadStrategy.new(definition_file_name)
    end

    def next_level
      if @active_member then
        @active_member = nil
        return self
      else
        return nil
      end
    end

    private

    # Returns the name of the file with the definition of the Level
    # (also known as Location datafile).

    def definition_file_name
      d = Dir.open @dirname
      basename = d.find {|filename| filename =~ /\.xml/}
      return @dirname + '/' + basename
    end
  end # class Level
end # module FreeVikings
