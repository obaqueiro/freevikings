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

module FreeVikings

  class ImageBank
    # Soubor obrazku pro mnozinu stavu sprajtu

    def initialize(sprite=nil)
      @images = Hash.new
      @sprite = sprite # odkaz na vyuzivajici sprite
    end

    def add_pair(state, image_object)
      @images[state] = image_object
      return self
    end

    # vrati surface s obrazkem pro prislusny stav

    def image
      if @images[@sprite.state.to_s].nil?
	raise RuntimeError, "No image assigned for a state #{@sprite.state.to_s}"
      end
      @images[@sprite.state.to_s].image
    end
  end

  class AnimationSuite
    # Skladba obrazku nebo animaci animujicich stav sprajtu

    MSEC_PER_SEC = 1000

    def initialize(delay = 1)
      @images = Array.new
      @delay = delay
    end

    def add(image_object)
      @images << image_object
      return self
    end

    def image
      return @images[(Time.now.to_i / @delay) % @images.size].image
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
	@image = RUDL::Surface.load_new(image_path)
      else
	@image = RUDL::Surface::new([1,1])
      end
    end

    def image
      @image
    end
  end # class Image

end
