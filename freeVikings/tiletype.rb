# tiletype.rb
# igneus 25.1.2005

# Trida pro typ dlazdice. Uchovava zejmena zobrazovaci a kvalitativni
# informace.

require 'imagebank'

module FreeVikings

  class TileType

    attr_accessor :solid

    @@instances = Hash.new

    def initialize(image_path)
      @image = Image.new(image_path)
      @solid = true
    end

    private_class_method :new

    # Pokud uz pro dany kod existuje instance, vrati ji, v opacnem pripade 
    # vytvori novou.

    def TileType.instance(code, image_path)
      unless @@instances[code].nil? then
	return @@instances[code]
      end

      @@instances[code] = new(image_path)
      return @@instances[code]
    end

    def image
      @image.image
    end
  end # class
end # module