# spritesheet.rb
# igneus 19.12.2008

module SchwerEngine

  # SpriteSheet is a simple way to load more images from one file at once.

  class SpriteSheet

    DEFAULT_COLORKEY = [255,0,255]

    # names_and_rects is a Hash where keys are strings
    # and values Rectangle instances

    private

    def common_init(filename)
      @images = {}
      @source = Image.new filename
    end

    public

    # Gets spritesheet image and hash of image names and rectangles.

    def initialize(filename, names_and_rects, colorkey=DEFAULT_COLORKEY)
      common_init filename

      names_and_rects.each_pair {|name,rect|
        #s = RUDL::Surface.new [rect.w, rect.h]
        #s.fill DEFAULT_COLORKEY
        #s.set_colorkey colorkey
        #s.blit @source.image, [0,0], rect.to_a
        subimage = @source.image.subimage(*rect.to_a)
        i = Image.wrap subimage
        @images[name] = i
      }

      if block_given?
        yield @source, @images, colorkey
      end
    end

    # Takes sizes of one frame and names of frames.

    def SpriteSheet.new2(filename, frame_width, frame_height, names, colorkey=DEFAULT_COLORKEY)
      return SpriteSheet.new(filename, {}, colorkey) do |source,images,ck|
        frames_h = (source.h/frame_height)
        frames_w = (source.w/frame_width)
        f = 0

        frames_h.times {|line|
          frames_w.times {|column|
            #s = RUDL::Surface.new [frame_width, frame_height]
            #s.fill DEFAULT_COLORKEY
            #s.set_colorkey colorkey
            #s.blit source.image, [0,0], [column*frame_width, line*frame_height, frame_width, frame_height]
            subimage = source.image.subimage(column*frame_width, line*frame_height, frame_width, frame_height)
            i = Image.wrap subimage

            break unless names[f]

            images[names[f]] = i

            f += 1
          }
          break unless names[f]
        }
      end
    end

    def SpriteSheet.load(filename, names_and_rects, colorkey=DEFAULT_COLORKEY)
      return SpriteSheet.new(SchwerEngine.config::GFX_DIR+'/'+filename,
                             names_and_rects, 
                             colorkey)
    end

    def SpriteSheet.load2(filename, frame_width, frame_height, names, colorkey=DEFAULT_COLORKEY)
      return SpriteSheet.new2(SchwerEngine.config::GFX_DIR+'/'+filename,
                              frame_width, 
                              frame_height, 
                              names, 
                              colorkey)
    end

    def [](i)
      @images[i]
    end

    # Says how many frames SpriteSheet has
    def frames
      @images.length
    end
  end
end
