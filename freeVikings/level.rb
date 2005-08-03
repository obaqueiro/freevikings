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
--- Level.new(dirname, member_of=nil)
Argument ((|dirname|)) is a name of the directory where all the data for
the ((<Level>)) are. There should be at least one XML file in the directory -
the file with the (({Location})) definition. Optionally there can be some
scripts (with .rb extension).
The second argument is for internal use only and points to a 'parent'
(({LevelSuite})).
=end

    def initialize(dirname, member_of=nil)
      super(dirname, member_of)
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
      xml_files = d.find_all {|filename| filename =~ /\.xml/}

      # Find the file which contains element 'location'
      # (it must be the location definition file):
      loc_def_basename = xml_files.find do |fname|
        file = File.open(@dirname + '/' + fname)
        file.find {|line| line =~ /<location/}
      end

      return @dirname + '/' + loc_def_basename
    end

    # We must override method, which is in the superclass called from
    # the constructor

    def load_from_xml
    end
  end # class Level
end # module FreeVikings
