# imagebank.rb
# igneus 20.1.2004

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

  end # class Animation

  class Image
    # Obrazek

    def initialize(image_path)
      if image_path.size != 0
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
