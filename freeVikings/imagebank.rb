# imagebank.rb
# igneus 20.1.2004

# Tridy:
#  Image          - Obal obrazku.
#  ImageBank      - Objekt s vazbou na sprajt. Vraci obrazek podle toho,
#                   jaky ma sprajt stav.
#  AnimationSuite - Vraci obrazek podle toho, kolik ubehlo casu. (animace)
#  Portrait       - Vymyka se obecnemu rozhrani. Metoda image sice jako jinde
#                   vraci Surface, ale neni dulezita. Dulezitejsi jsou
#                   metody active, unactive a kaput. Objekt Portrait
#                   je schranka na portrety postavy, ktere se pouzivaji
#                   ve stavovem radku.

require 'RUDL'

module FreeVikings

=begin
= ImageBank
((<ImageBank>)) is an associative container which binds a Sprite, it's states
and images for these states.
=end

  class ImageBank

    def initialize(sprite=nil, hash=nil)
      @log = Log4r::Logger['images log']

      @log.info "Creating a new ImageBank for sprite #{sprite} #{ hash ? "Pre-prepared images hash was provided." : "." }"

      @images = Hash.new
      @sprite = sprite # odkaz na vyuzivajici sprite
      if hash then
        hash.each_key {|key| add_pair(key, hash[key])}
      end
    end

=begin
--- ImageBank#add_pair(state, image_object)
Associates the FreeVikings::Image object with a state state (usually a String,
eventually a Numeric, a boolean value or something else).
It controls if the image has sizes equal to the sizes of the sprite which is 
the ImageBank's owner. If the sizes aren't same, RuntimeError is thrown.
This exception is thrown after the image is associated with the state, so you 
can just catch the exception and go on without problems.
=end

    def add_pair(state, image_object)
      @log.debug "Associating image #{image_object.to_s} - #{image_object.name} with a state #{state.to_s}"
      @images[state] = image_object
      if image_object.w != @sprite.rect.w or
          image_object.h != @sprite.rect.h then
        raise ImageWithBadSizesException, "A problem accured while associating image #{image_object.name} with the state #{state.to_s} (owner of the ImageBank: #{@sprite.to_s}): It is strange to have an image of size #{image_object.w}x#{image_object.h} and a sprite of size #{@sprite.rect.w}x#{@sprite.rect.h} (usually the sizes should be same)."
      end
      return self
    end

=begin
--- ImageBank#image
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
== ImageWithBadSizesException
This exception is thrown when an image which has different sizes than
the owner is added into an ((<ImageBank>)). It's important that the exception
is thrown just ((*after*)) the image is added, so if you expect it, you
can catch the exception and carry on whistling...
=end
    class ImageWithBadSizesException < RuntimeError
    end

=begin
== NoImageAssignedException
Exceptions of this type are thrown by ((<ImageBank#image>)) if there
is no image for the owner's state in the ((<ImageBank>)).
=end
    class NoImageAssignedException < RuntimeError
      def initialize(state)
        @message = "No image assigned for a state #{state.to_s}."
      end
      attr_reader :message
      alias_method :to_s, :message
    end # class NoImageAssignedException
  end # class ImageBank


=begin
= AnimationSuite
((<AnimationSuite>)) is a simple class which allows you to use animated
images (e.g. inside an ((<ImageBank>))).
=end

  class AnimationSuite
    # Skladba obrazku nebo animaci animujicich stav sprajtu

    MSEC_PER_SEC = 1000

    def initialize(delay = 1, images=nil, name="Unnamed Animation")
      if images
        @images = images
      else
        @images = Array.new
      end
      @delay = delay
      @name = name
    end

    attr_reader :name

    def add(image_object)
      @images << image_object
      return self
    end

    def image
      return @images[(Time.now.to_i / @delay) % @images.size].image
    end

    def w
      image.w
    end

    def h
      image.h
    end

  end # class AnimationSuite


=begin
= Portrait
A ((<Portrait>)) keeps three images. They are called active, unactive and 
kaput. Every of the three vikings has his own ((<Portrait>)) object with 
his face's images used on the BottomPanel.
=end

  class Portrait

    def initialize(active_path, unactive_path, kaput_path)
      @active = Image.load(active_path)
      @unactive = Image.load(unactive_path)
      @kaput = Image.load(kaput_path)
    end

    def image
      @active.image
    end

    def active
      @active.image
    end

    def unactive
      @unactive.image
    end

    def kaput
      @kaput.image
    end
  end # class Portrait


=begin
= Image
((<Image>)) is a wrapper class for Image data (at the moment the internal 
datatype is RUDL::Surface, but it can change one day).
=end

  class Image

=begin
--- Image.new(filename='')
Loads image data from file. If no filename specified, makes an empty image 
of size 1*1px.
=end

    def initialize(filename='')
      if filename.size != 0
        begin
          @image = RUDL::Surface.load_new(filename)
        rescue SDLError => ex
          raise ImageFileNotFoundException, ex.message
        end
      else
	@image = RUDL::Surface::new([1,1])
      end
      @name = filename
    end

=begin
--- Image.load(filename)
Loads image placed relatively to the directory specified in the constant
(({GFX_DIR})).
=end

    def Image.load(filename)
      Image.new(GFX_DIR+'/'+filename)
    end

    attr_reader :name

    def image
      @image
    end

    def w
      @image.w
    end

    def h
      @image.h
    end

    # Vyjimka tohoto typu je vyhozena, pokud soubor s obrazkem, ktery ma 
    # byt nahran, neexistuje.
    class ImageFileNotFoundException < RuntimeError
    end

  end # class Image
end # module FreeVikings
