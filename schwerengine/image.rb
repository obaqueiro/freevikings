# image.rb
# igneus 26.11.2005

=begin
= NAME
Image

= DESCRIPTION
((<Image>)) is a wrapper class for Image data (at the moment the internal 
datatype is RUDL::Surface, but it can change one day).

= Superclass
Object
=end

module SchwerEngine
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
      Image.new(SchwerEngine.config::GFX_DIR+'/'+filename)
    end

=begin
--- Image.wrap(surface)
Doesn't load image from file and creates it by wrapping an existing
(({RUDL::Surface})) instead.
=end

    def Image.wrap(surface)
      i = Image.new
      i.instance_eval {
        @name = "Wrapped RUDL::Surface"
        @image = surface
      }
      return i
    end

    attr_reader :name

    def image
      @image
    end

    alias_method :surface, :image

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
end # module SchwerEngine
