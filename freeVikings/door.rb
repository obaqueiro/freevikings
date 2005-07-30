# door.rb
# igneus 31.7.2005

=begin
= Door
((<Door>)) is a two-state static object. When it is closed (default state),
it's solid. When it is open, it's soft.
It's usually connected with a (({Switch})) or a (({Lock})).
=end

require 'entity.rb'

module FreeVikings

  class Door < Entity

    WIDTH = 40
    HEIGHT = 120

=begin
--- Door.new(position, closed=true)
You must specify the position (it's common for all the types derived
from (({Entity}))) and optionally if the ((<Door>)) is closed, default is true.
=end

    def initialize(position, closed=true)
      super(position)
      @closed = true
    end

=begin
--- Door#solid
--- Door#solid?
These methods (aliases of each other) answer the question "is the ((<Door>))
solid?" by ((|true|)) or ((|false|)).
=end

    def solid
      @closed ? true : false
    end

=begin
--- Door#open
Makes the ((<Door>)) open.
=end

    def open
      @closed = false
      self
    end

=begin
--- Door#close
Closes the ((<Door>)).
=end

    def close
      @closed = true
      self
    end

=begin
--- Door#state
Returns (('"open"')) or (('"closed"')). This method is here mainly for 
the needs of (({ImageBank})).
=end

    def state
      @closed ? 'closed' : 'open'
    end

=begin
--- Door#init_images
Initializes the images. It's called from the constructor of (({Entity})).
=end

    def init_images
      @image = ImageBank.new self
      begin
        @image.add_pair "closed", Image.load('door_closed.tga')
        @image.add_pair "open", Image.load('door_open.tga')
      rescue ImageBank::ImageWithBadSizesException
        # There's no problem. ImageBank is angry, because the image
        # for the 'open' state is wider, but in this state the Door is soft,
        # so the alarm is idle.
      end
    end
  end # class Door
end # module FreeVikings
