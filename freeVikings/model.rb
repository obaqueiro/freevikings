# images.rb
# igneus 20.1.2004

require 'RUDL'

module FreeVikings

=begin
= NAME
Model

= DESCRIPTION
((<Model>)) is an associative container which binds a Sprite, it's states
and images for these states.

= Superclass
Object
=end

  class Model

=begin
--- Model.new(sprite, hash=nil)
* ((|sprite|)) is the state machine of the (({Model})). It is usually
  the (({Sprite})) which uses it, but it isn't needed to be strictly so.
  It must respond to (({state})).
* ((|hash|)) is an optional argument. It can contain hash with (({String}))
  keys and (({Image})) compatible values. It is used as a set of
  state=>image pairs if supplied.

Example:
Let's have a (({Sprite})) ((|bar|)). We want to make an (({Model}))
for it.

i = Image.load 'foo.png'

- one way of doing things

  bank = Model.new(bar)
  bank.add_pair 'foo_state', i

- another way which is as good as the first one

  bank = Model.new(bar, {'foo_state' => i})
=end

    def initialize(sprite, hash=nil)
      @log = Log4r::Logger['images log']

      @log.info "Creating a new Model for sprite #{sprite} #{ hash ? "Pre-prepared images hash was provided." : "." }"

      @images = Hash.new
      @sprite = sprite # odkaz na vyuzivajici sprite
      if hash then
        hash.each_key {|key| add_pair(key, hash[key])}
      end
    end

=begin
--- Model#add_pair(state, image_object)
Associates the FreeVikings::Image object with a state state (usually a String,
eventually a Numeric, a boolean value or something else).
It controls if the image has sizes equal to the sizes of the sprite which is 
the Model's owner. If the sizes aren't same, RuntimeError is thrown.
This exception is thrown after the image is associated with the state, so you 
can just catch the exception and go on without problems.
=end

    def add_pair(state, image_object)
      @log.debug "Associating image #{image_object.to_s} - #{image_object.name} with a state #{state.to_s}"
      @images[state] = image_object
      if image_object.w != @sprite.rect.w or
          image_object.h != @sprite.rect.h then
        raise ImageWithBadSizesException, "A problem accured while associating image #{image_object.name} with the state #{state.to_s} (owner of the Model: #{@sprite.to_s}): It is strange to have an image of size #{image_object.w}x#{image_object.h} and a sprite of size #{@sprite.rect.w}x#{@sprite.rect.h} (usually the sizes should be same)."
      end
      return self
    end

=begin
--- Model#image
Returns the Image for owner's recent state.
=end

    def image
      begin
        @images[@sprite.state.to_s].image
      rescue NoMethodError
	raise NoImageAssignedException.new(@sprite.state)
      end
    end

=begin
-- Model::ImageWithBadSizesException (exception class)
This exception is thrown when an image which has different sizes than
the owner is added into an ((<Model>)). It's important that the exception
is thrown just ((*after*)) the image is added, so if you expect it, you
can catch the exception and carry on whistling...
=end
    class ImageWithBadSizesException < RuntimeError
    end

=begin
-- Model::NoImageAssignedException (exception class)
Exceptions of this type are thrown by ((<Model#image>)) if there
is no image for the owner's state in the ((<Model>)).
=end
    class NoImageAssignedException < RuntimeError
      def initialize(state)
        @message = "No image assigned for a state #{state.to_s}."
      end
      attr_reader :message
      alias_method :to_s, :message
    end # class NoImageAssignedException
  end # class Model
end # module FreeVikings
