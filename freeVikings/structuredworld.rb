# structuredworld.rb
# igneus 1.8.2005

require 'levelsuite.rb'

module FreeVikings

  class StructuredWorld

    # Argument campaign_dir is a name of the root directory 
    # of the LevelSuite hierarchy. It's also called 'a campaign directory',
    # because it contains a complete set of levels, which is also called 
    # 'a campaign'.
    #
    # (If you wanted, you wouldn't have to give a real 'campaign directory' 
    # as argument, it is possible to give a directory of any nested LevelSuite,
    # but it isn't very usual.)
    #
    # The second argument, password, is voluntary and must be a 4-character
    # String. If it is given location with password password is selected as 
    # a starting location.

    def initialize(campaign_dir)
      # @levelsuite = LevelSuite.new(campaign_dir)
      @levelsuite = LevelSuite.factory campaign_dir
    end

    # Both 'level' and 'location' are nil until you first call next_level!

    # Returns current Level

    attr_reader :level

    # Returns current Location

    attr_reader :location

    # Does the same as next_location, but returns Level, not Location.
    # After StructuredWorld#next_level you can get the current Location
    # by call to StructuredWorld#rewind_location.

    def next_level(password='')
      # Load level with given password:
      if password != '' then
        unless Level.valid_level_password?(password)
          raise PasswordError, "Password \"#{password}\" of type #{password.class} isn't a valid location password. A valid password must be #{Level::LEVEL_PASSWORD_LENGTH} characters long and may contain alphanumeric characters only."
        end
        @level = @levelsuite.level_with_password(password)
        create_location
        return @level
      end

      # Loading without password:
      @level = @levelsuite.next_level
      create_location
      return @level
    end

    def rewind_location
      return create_location
    end

    # Returns Array of all Levels of the world

    def levels
      @levelsuite.levels
    end

    private

    def create_location
      if @level.nil? then
        raise NoMoreLevelException, "No more level found. Currently loaded LevelSuite from directory '#{@levelsuite.dirname}'."
      end

      @location = Location.new(@level.loader, @level.gfx_theme)
    end

    public

    # Exception raised if invalid password is given.

    class PasswordError < ArgumentError
    end

    # Raised by create_location if there is no more level.

    class NoMoreLevelException < RuntimeError
    end
  end # class StructuredWorld
end # module FreeVikings
