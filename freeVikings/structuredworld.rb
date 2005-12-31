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

    def initialize(campaign_dir, password='')
      @levelsuite = LevelSuite.new(campaign_dir)

      next_location(password)
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

=begin
--- StructuredWorld#next_location(password='')
If you use the voluntary argument, a (({Location})) with the specified
password is run instead of the next one.
=end

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

    private

    def create_location
      @location = Location.new(@level.loader, @level.gfx_theme)
    end

    public

=begin
--- StructuredWorld::PasswordError
Exception raised if invalid password is given.
=end

    class PasswordError < ArgumentError
    end
  end # class StructuredWorld
end # module FreeVikings
