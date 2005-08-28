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
--- StructuredWorld(campaign_dir, password=nil)
Argument ((|campaign_dir|)) is a name of the root directory 
of the (({LevelSuite})) hierarchy. It's also called 'a campaign directory',
because it contains a complete set of levels, which is also called 
'a campaign'.

(If you wanted, you wouldn't have to give a real 'campaign directory' 
as argument, it is possible to give a directory of any nested (({LevelSuite})),
but it isn't very usual.)

The second argument, ((|password|)), is voluntary and must be a 4-character
String. If it is given location with password ((|password|)) is selected as 
a starting location.
=end

    def initialize(campaign_dir, password=nil)
      @levelsuite = LevelSuite.new(campaign_dir)

      if password then
        unless password.valid_location_password?
          raise ArgumentError, "Password \"#{password}\" of type #{password.class} isn't a valid location password. A valid password must be #{String::LOCATION_PASSWORD_LENGTH} characters long and may contain alphanumeric characters only."
        end
        @level = @levelsuite.level_with_password(password)
        create_location
      else
        next_location
      end
    end

    attr_reader :level

=begin
--- StructuredWorld#next_level
Does the same as next_location, but returns (({Level})), not (({Location})).
Dont't call ((<StructuredWorld#next_location>)) after 
((<StructuredWorld#next_level>)), you would skip one location!
After ((<StructuredWorld#next_level>)) you can get the current (({Location}))
by call to ((<StructuredWorld#rewind_location>)).
=end

    def next_level
      @level = @levelsuite.next_level

      if @level == nil then
        return nil
      end

      return @level
    end

    def next_location
      next_level
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

=begin
= String
For needs of ((<StructuredWorld>)) class ((<String>)) is extended.
=end

class String
  LOCATION_PASSWORD_LENGTH = 4

=begin
--- String#valid_location_password?
Says if a ((<String>)) is a valid location password.
=end
  def valid_location_password?
    # valid location password must be 4 characters long and may
    # only contain word characters and digits
    size == LOCATION_PASSWORD_LENGTH and /^[\d\w]+$/ =~ self
  end
end
