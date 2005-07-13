# tiletype.rb
# igneus 25.1.2005

# Trida pro typ dlazdice. Uchovava zejmena zobrazovaci a kvalitativni
# informace.

require 'imagebank'

module FreeVikings

  class Tile

    attr_accessor :solid
    alias_method :solid?, :solid

    @@instances = Hash.new

    def initialize(image_path)
      if image_path and image_path.size != 0 then
        @image = Image.load(image_path)
      else
        @image = Image.new
      end
      @solid = true
    end

    private_class_method :new

    # Vymaze vsechny instance z interniho slovniku tridy.
    # Tuto metodu je treba zavolat vzdy pred nahravanim 
    # typu dlazdic z nove lokace.

    def Tile.clear
      @@instances.clear
    end

    # Pokud uz pro dany kod existuje instance, vrati ji, v opacnem pripade 
    # vytvori novou.

    def Tile.instance(code, image_path)
      unless @@instances[code].nil? then
	return @@instances[code]
      end

      @@instances[code] = new(image_path)
      return @@instances[code]
    end

    def image
      return @image.image
    end
  end # class
end # module
