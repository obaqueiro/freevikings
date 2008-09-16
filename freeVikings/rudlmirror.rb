# rudlmirror.rb
# igneus 8.9.2008

require 'RUDL'

# Extension of RUDL::Surface.

module RUDL
  class Surface

    # Returns an y-mirrorred copy of self

    def mirror_y
      product = Surface.new(size, flags, bitsize, masks)

      puts flags
      puts product.flags
      rows.reverse.each_with_index {|r,i| 
        product.set_row(i, r)
      }

      if palette
        product.set_palette 0, palette
      end

      if colorkey
        product.set_colorkey colorkey
      end

      return product
    end

    # Returns a x-mirrorred copy of self

    def mirror_x
      product = Surface.new(size, flags, bitsize, masks)

      columns.reverse.each_with_index {|c,i| 
        product.set_column(i, c)
      }

      if palette
        product.set_palette 0, palette
      end

      if colorkey
        product.set_colorkey colorkey
      end

      return product
    end
  end
end

if __FILE__ == $0 then
  include RUDL
  d = DisplaySurface.new [120,60]

  i = Surface.load_new 'gfx/key_red.tga'
  d.blit i, [0,0]
  d.blit i.mirror_x, [30,0]
  d.blit i.mirror_y, [60,0]

  j = Surface.load_new 'gfx/apple.png'
  d.blit j, [0,30]
  d.blit j.mirror_x, [30,30]
  d.blit j.mirror_y, [60,30]

  d.flip
  loop do 
    EventQueue.get.each {|e|
      exit if e.is_a? QuitEvent
    }
    sleep 1
  end
end
