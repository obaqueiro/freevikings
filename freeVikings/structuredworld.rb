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

    def initialize(campaign_dir, password='')
      @levelsuite = LevelSuite.new(campaign_dir)

      next_location(password)
    end

    # Returns current Level

    attr_reader :level

    # Returns current Location

    attr_reader :location

    # Does the same as next_location, but returns Level, not Location.
    # Dont't call StructuredWorld#next_location after 
    # StructuredWorld#next_level, you would skip one location!
    # After StructuredWorld#next_level you can get the current Location
    # by call to StructuredWorld#rewind_location.

    def next_level
      @level = @levelsuite.next_level

      if @level == nil then
        return nil
      end

      return @level
    end

    # If you use the voluntary argument, a Location with the specified
    # password is run instead of the next one.

    def next_location(password='')
      if password != '' then
        unless FreeVikings.valid_location_password?(password)
          raise PasswordError, "Password \"#{password}\" of type #{password.class} isn't a valid location password. A valid password must be #{String::LOCATION_PASSWORD_LENGTH} characters long and may contain alphanumeric characters only."
        end
        @level = @levelsuite.level_with_password(password)
        create_location
      else
        next_level
        return create_location
      end
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
        raise "No more level found. Currently loaded LevelSuite from directory '#{@levelsuite.dirname}'."
      end

      @location = Location.new(@level.loader, @level.gfx_theme)
    end

    public

    # Exception raised if invalid password is given.

    class PasswordError < ArgumentError
    end
  end # class StructuredWorld
end # module FreeVikings
