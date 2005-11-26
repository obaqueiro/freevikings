# animation.rb
# igneus 26.11.2005

=begin
= NAME
Animation

= DESCRIPTION
((<Animation>)) is a simple class which allows you to use animated
images (e.g. inside an ((<Model>))).

= Superclass
Object
=end

require 'forwardable'

module FreeVikings
  class Animation

    extend Forwardable

    MSEC_PER_SEC = 1000

=begin
--- Animation.new(delay = 1, images=nil, name="Unnamed Animation")
* ((|delay|)) (in seconds) is how long one image is displayed
* ((|images|)) is an (({Array})) of (({Image}))-like objects
=end

    def initialize(delay = 1, images=nil, name="Unnamed Animation")
      if images
        @images = images
      else
        @images = Array.new
      end
      @delay = delay
      @name = name
    end

=begin
--- Animation#name
=end

    attr_reader :name

=begin
--- Animation#add(image_object)
--- Animation#push(image_object)
--- Animation#append(image_object)
Appends an (({Image}))-like object to the animation.
=end

    def push(image_object)
      @images.push image_object
      return self
    end

    alias_method :add, :push
    alias_method :append, :push

=begin
--- Animation#prepend(image_object)
Adds an (({Image}))-like object at the beginning of the animation.
=end

    def_delegator :@images, :unshift, :prepend

=begin
--- Animation#image
Method common for all the (({Image}))-like objects. Returns the current image
(a (({RUDL::Surface})) instance).
=end

    def image
      return @images[(Time.now.to_i / @delay) % @images.size].image
    end
  end # class Animation
end # module FreeVikings



