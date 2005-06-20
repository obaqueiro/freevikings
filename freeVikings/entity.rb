# entity.rb
# igneus 19.6.2005

module FreeVikings

=begin
= Entity
Entity is a superclass for all the classes which appear in the freeVikings'
world. It's most famous subclass is ((<Sprite>)).
=end
  class Entity

    def initialize(initial_position=[])
      unless initial_position.empty?
	@rect = Rectangle.new(initial_position[0], 
                              initial_position[1], 
                              (initial_position[2] ? initial_position[2] : 0),
                              (initial_position[3] ? initial_position[3] : 0))
      else
	@rect = Rectangle.new(0,0,0,0)
      end

      @location = NullLocation.new
      @image = Image.new('nobody.tga')

      init_images if self.respond_to? :init_images
    end

    attr_reader :rect
  end # class Entity
end # module FreeVikings
