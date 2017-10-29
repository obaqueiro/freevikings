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
--- Image.new(filename)
Loads image data from file.
=end

    def initialize(filename=nil)
      return if filename.nil?

      begin
        @image = Gosu::Image.new(filename)
      rescue RuntimeError => ex
        raise ImageFileNotFoundException, ex.message
      end

      @name = filename
    end

=begin
--- Image.load(filename)
Loads image placed relatively to the directory specified in the constant
(({GFX_DIR})).
=end

    def self.load(filename)
      new(SchwerEngine.config::GFX_DIR+'/'+filename)
    end

=begin
--- Image.wrap(surface)
Doesn't load image from file and creates it by wrapping an existing
(({RUDL::Surface})) instead.
=end

    def self.wrap(surface)
      i = new
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
      @image.width
    end

    def h
      @image.height
    end

    # Return mirrored copy of self

    def mirror_x
      Image.wrap @image.mirror_x
    end

    def mirror_y
      Image.wrap @image.mirror_y
    end

    class ImageFileNotFoundException < RuntimeError
    end
  end # class Image
end # module SchwerEngine
