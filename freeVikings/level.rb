# level.rb
# igneus 1.8.2005

require 'locationloader.rb'
require 'levelsuite.rb'

module FreeVikings

  # Level is a subclass of LevelSuite. It provides the same interface
  # plus method Level#loader which returns 
  # the LocationLoadStrategy to load the Level data into the
  # Location instance.
  # So don't confuse Level and Location!
  # Level is a minimalistic object which contains only a few information
  # needed to load the level data. Location is a huge heap of objects
  # which play their roles in the game.

  class Level < LevelSuite

    DEFINITION_FILE_NAME = 'location.xml'

    # Argument dirname is a name of the directory where all the data for
    # the Level are. There should be at least one XML file in the directory -
    # the file with the Location definition. Optionally there can be some
    # scripts (with .rb extension).
    # The second argument is for internal use only and points to a 'parent'
    # LevelSuite.

    def initialize(dirname, member_of=nil)
      @log = Log4r::Logger['world log']

      super(dirname, member_of)
      load_from_xml
      @active_member = self
      @log.debug "Initialized a new level: directory: \"#{@dirname}\"; password: \"#{@password}\";"
    end

    # Says if specified directory contains the Level definition file.

    def Level.is_level_directory?(dirname)
      deffile = dirname+'/'+DEFINITION_FILE_NAME
      if File.exist?(deffile)
        return true
      else
        return false
      end
    end

    # Returns level's password

    attr_reader :password

    # Returns level's music file or nil

    attr_reader :music

    # Returns a LocationLoadStrategy instance which is able to load 
    # the data from the @dirname directory into the Location object.

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
      # A few levels have their own theme:
      if @theme then
        return @theme
      end

      # The others use their parent LevelSuite's one:
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
      @password = ''
      @title = ''
      @music = nil

      file = @dirname + '/' + DEFINITION_FILE_NAME
      fr = File.open(file)
      doc = REXML::Document.new fr

      begin
        @password = doc.root.elements['body/password'].text
      rescue NoMethodError
        @log.error "Level password not defined"
        @password = ''
      end
      begin
        @music = doc.root.elements['body/music'].text
      rescue NoMethodError
        @music = nil
      end
      begin
        @title = doc.root.elements['info/title'].text
      rescue NoMethodError
        @log.warn "Level title not defined"
        @title = ''
      end

      begin
        @theme_name = doc.root.elements['body/theme'].text
        @theme = load_theme
      rescue NoMethodError
      end
    
      unless FreeVikings.valid_location_password?(@password)
        @log.error "Invalid location password '#{@password}'. Setting default (empty String)."
        @password = ''
      end
    end

  end # class Level
end # module FreeVikings
