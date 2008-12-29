# entity.rb
# igneus 19.6.2005

module SchwerEngine

  # Nearly everything that has it's image and it's place on the game world is 
  # an Entity.

  class Entity

    # Default width and height of the Entity (in pixels).
    # Subclasses can redefine it but it's mainly for the internal use and isn't
    # compulsory.

    WIDTH = HEIGHT = 0

    DEFAULT_Z_VALUE = 0

    # Arguments:
    # initial_position:: should be a Rectangle or an Array.
    #   If it is an Array and WIDTH and HEIGHT constants
    #   are defined you can omit the third and fourth item of the Array
    # theme:: should be a GfxTheme.
    #   It provides the possibility of using different images for the same
    #   Entity in different levels.
    #
    # If the object defines a public method (({init_images})), this method is 
    # called. It can be used to load the images for the ((<Entity>)).
    #
    # class SomeMonster < Entity
    #   WIDTH = 30
    #   HEIGHT = 80
    # end
    #
    # SomeMonster.new([120, 120])
    # SomeMonster.new([120, 120, 30, 80])
    # SomeMonster.new(Rectangle.new(120, 120, 30, 80))
    # SomeMonster.new(Rectangle.new(120, 120, 30, 80), some_gfx_theme)

    def initialize(initial_position=[], theme=NullGfxTheme.instance)
      unless initial_position.empty?
	@rect = Rectangle.new(initial_position[0], 
                              initial_position[1], 
                              (initial_position[2] or self.class::WIDTH),
                              (initial_position[3] or self.class::HEIGHT))
      else
	@rect = Rectangle.new(0,0,0,0)
      end

      @image = Image.load('nobody.tga')

      @theme = theme

      @z = self.class::DEFAULT_Z_VALUE

      init_images if self.respond_to? :init_images
    end

    # Returns the RUDL::Surface object with an image which represents
    # the Entity in the game.

    def image
      if @image.kind_of? Model then
        return @image.image(self)
      else
        return @image.image
      end
    end

    # These two methods should always be aliases of each other.
    attr_reader :rect
    alias_method :collision_rect, :rect

    # Number which tells in which layer the object is. Objects with
    # higher numbers are painted later (in front of the others with lower 
    # numbers).
    # Default value for most objects is 0.
    attr_reader :z

    # Rectangle of the graphics. By default it is the same 
    # as Entity#collision_rect.
    alias_method :paint_rect, :rect

    attr_accessor :location

    # Adds itself into a Location location.
    # Does all the registration stuff transparently (some objects register 
    # themselves
    # as sprites, some as static objects, some need to play multiple roles 
    # (e.g.
    # sprite & static object, sprite & active object, ...), but we don't need
    # to bother, the object knows what it needs).

    def register_in(location)
      raise "Not implemented. Implemented in subclasses only."
    end

    # Says if the Entity is a Null Object.
    #
    # Note: Null Object
    # Maybe you don't know anything about the Design Patterns. Then you 
    # should know
    # about one of them, it's known as 'Null Object'. How does it work?
    # On some places either a regular object or nil is expected.
    # If a regular object is given, something is done with it, otherwise
    # nothing happens.
    # But it is very uncomfortable to test everywhere if you are working with
    # a regular object or with nil. You can reach the same goal by using
    # a Null Object. It's an object which contains no data and it's methods do 
    # nothing, but they behave like they would if the object was normal.

    def null?
      false
    end

    # In the GfxTheme images are named by symbolic names.
    # This method tries to get an image from the GfxTheme which was given
    # as argument to the constructor.
    # If the image isn't found, GfxTheme::UnknownNameException is thrown.

    def get_theme_image(name)
      if @theme.null? then
        raise NullThemeException, "The #{self.class.to_s}'s instance variable '@theme' contains a Null Object (instance of #{@theme.class}). No images can be loaded. (Maybe you should inform this Entity about the current theme.)"
      end

      @theme[name]
    end

    # A class of exceptions which are thrown by method Entity#get_theme_image
    # if instance variable @theme is a NullGfxTheme instance.
    # (This exception is here to help the implementors of monsters and new 
    # levels. 
    # It's a common error that the levelmaker forgets to give the monster 
    # a current  theme and the poor monster then isn't able to load it's 
    # images.)

    class NullThemeException < RuntimeError 
    end # class NullThemeException
  end # class Entity
end # module FreeVikings
