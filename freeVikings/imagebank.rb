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
require 'log4r'

module FreeVikings

  class ImageBank
    # Soubor obrazku pro mnozinu stavu sprajtu

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

    # vrati surface s obrazkem pro prislusny stav

    def image
      begin
        @images[@sprite.state.to_s].image
      rescue NoMethodError
	raise RuntimeError, "No image assigned for a state #{@sprite.state.to_s}."
      end
    end

    # Vyjimky teto tridy jsou vyhazovany, pokud dojde k pokusu o zarazeni
    # obrazku, jenz velikosti neodpovida velikosti spritu, jemuz dana 
    # ImageBank patri.
    class ImageWithBadSizesException < RuntimeError
    end
  end # class ImageBank

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


  class Portrait

    def initialize(active_path, unactive_path, kaput_path)
      @active = Image.new(active_path)
      @unactive = Image.new(unactive_path)
      @kaput = Image.new(kaput_path)
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


  class Image
    # Obrazek

    # Vytvori obrazek. Zadanou cestu vezme relativne ke standardnimu
    # adresari obrazku.

    def initialize(image_path='')
      if image_path.size != 0
	image_path = GFX_DIR+'/'+image_path
        begin
          @image = RUDL::Surface.load_new(image_path)
        rescue SDLError => ex
          raise ImageFileNotFoundException, ex.message
        end
      else
	@image = RUDL::Surface::new([1,1])
      end
      @name = image_path
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

end
