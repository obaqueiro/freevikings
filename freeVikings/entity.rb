# entity.rb
# igneus 19.6.2005

=begin
= Entity
Entity is a superclass for all the classes which appear in the freeVikings'
world. It's most famous subclass is ((<Sprite>)).
Everything that has it's image and it's place on the world is an Entity.
=end

module FreeVikings

  class Entity

    WIDTH = HEIGHT = 0

=begin
--- Entity.new(initial_position=[], theme=NullGfxTheme.instance)
Argument ((|initial_position|)) should be a (({Rectangle})) or an (({Array.})).
The second (voluntary) parameter, ((|theme|)) should be a (({GfxTheme})).
It provides the possibility of using different images for the same
((<Entity>)) in different levels.
If the object defines a public method (({init_images})), this method is called.
It can be used to load the images for the ((<Entity>)).
=end

    def initialize(initial_position=[], theme=NullGfxTheme.instance)
      unless initial_position.empty?
	@rect = Rectangle.new(initial_position[0], 
                              initial_position[1], 
                              (initial_position[2] ? initial_position[2] : self.class::WIDTH),
                              (initial_position[3] ? initial_position[3] : self.class::HEIGHT))
      else
	@rect = Rectangle.new(0,0,0,0)
      end

      @image = Image.load('nobody.tga')

      @theme = theme

      init_images if self.respond_to? :init_images
    end

=begin
--- Entity#image
Returns the (({RUDL::Surface})) object with an image which represents
the ((<Entity>)) in the game.
=end

    def image
      @image.image
    end

    attr_reader :rect

=begin
--- Entity#null?
Maybe you don't know anything about the Desigh Patterns. Then you should know
about one of them, it's known as 'Null Object'. How does it work?
Some methods normally return a regular object or ((|nil|)). Then you must
control what you have (((|nil|)) usually doesn't have the methods you need).
Instead of ((|nil|)) you can often return an object which has no contents,
but provides all the methods. This is a Null Object.
Only Null Objects return ((|true|)) from this predicate method.
=end

    def null?
      false
    end

=begin
--- Entity#load_theme_image(name)
In the (({GfxTheme})) images are named by symbolic names.
This method tries to get an image from the (({GfxTheme})) which was given
as argument to the constructor.
If the image isn't found, (({GfxTheme::UnknownNameException})) is thrown.
=end

    def get_theme_image(name)
      if @theme.null? then
        raise NullThemeException, "The #{self.class.to_s}'s instance variable '@theme' contains a Null Object (instance of #{@theme.class}). No images can be loaded. (Maybe you should inform this Entity about the current theme.)"
      end

      @theme[name]
    end

=begin
--- Entity::NullThemeException
A class of exceptions which are thrown by method ((<Entity#get_theme_image>))
if instance variable ((|@theme|)) is a (({NullGfxTheme})) instance.
(This exception is here to help the implementors of monsters and new levels. 
It's an oft error that the levelmaker forgets to give the monster a current 
theme and the poor monster then isn't able to load it's images.)
=end

    class NullThemeException < RuntimeError 
    end # class NullThemeException
  end # class Entity
end # module FreeVikings
