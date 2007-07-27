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

require 'locationloader.rb'
require 'levelsuite.rb'

module FreeVikings

  class Level < LevelSuite

    DEFINITION_FILE_NAME = 'location.xml'

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
      @log = Log4r::Logger['world log']

      super(dirname, member_of)
      @title = "Level " + File.basename(dirname)
      @active_member = self
      @password = load_password
      @log.debug "Initialized a new level: directory: \"#{@dirname}\"; password: \"#{@password}\";"
    end

=begin
--- Level.is_level_directory?(dirname)
Says if specified directory contains the Level definition file.
=end

    def Level.is_level_directory?(dirname)
      deffile = dirname+'/'+DEFINITION_FILE_NAME
      if File.exist?(deffile)
        return true
      else
        return false
      end
    end

=begin
--- Level#password
=end

    attr_reader :password

=begin
--- Level#loader
Returns a (({LocationLoadStrategy})) instance which is able to load 
the data from the ((|@dirname|)) directory into the (({Location})) object.
=end

    def loader
      file = @dirname+'/'+DEFINITION_FILE_NAME
      @log.debug "Returned loader encapsulating file '#{file}'."

      unless File.exist? file
        raise "Location definition file '#{file}' doesn't exist."
      end

      return LocationLoader.new(File.new(file))
    end

    def next_level
      if @active_member then
        @active_member = nil
        return self
      else
        return nil
      end
    end

    def level_with_password(password)
      raise "Senseless method call!!! Method only used in superclass!!!"
    end

    def gfx_theme
      if @member_of then
        return @member_of.gfx_theme
      else
        msg = "Level isn't a member of any LevelSuite -> it can't access any GfxTheme - caller provided with NullGfxTheme"
        @log.warn msg
        return NullGfxTheme.instance
      end
    end

    private

    # We must override method, which is in the superclass called from
    # the constructor

    def load_from_xml
    end

    # Tries to load the level password from file PASSWORD

    def load_password
      password = ''

      file = @dirname + '/' + DEFINITION_FILE_NAME
      File.open(file) do |fr|
        while l = fr.gets do
          # Meaning of the following three lines isn't obvious unless
          # you know how regular expressions work in Perl (and Ruby).
          # Characters matching parenthesized sections of the regexp are
          # assigned into global variables $1, $2, etc.
          # So if l matches the regexp, text between '<password>' and
          # '</password>' is assigned into $1.
          if l =~ /<password>(.+)<\/password>/ then
            password = $1.strip
          end
        end
      end
    
      unless FreeVikings.valid_location_password?(password)
        @log.warn "Invalid location password '#{password}'. Setting default (empty String)."
        password = ''
      end

      return password
    end
  end # class Level
end # module FreeVikings
