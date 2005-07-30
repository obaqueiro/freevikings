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

=begin
--- Entity.new(initial_position=[])
Argument ((|initial_position|)) should be a (({Rectangle})) or an (({Array.})).
If the object defines a public method (({init_images})), this method is called.
It can be used to load the images for the ((<Entity>)).
=end

    def initialize(initial_position=[])
      unless initial_position.empty?
	@rect = Rectangle.new(initial_position[0], 
                              initial_position[1], 
                              (initial_position[2] ? initial_position[2] : 0),
                              (initial_position[3] ? initial_position[3] : 0))
      else
	@rect = Rectangle.new(0,0,0,0)
      end

      @image = Image.load('nobody.tga')

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
  end # class Entity
end # module FreeVikings
