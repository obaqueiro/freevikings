# penguin.rb
# igneus 22.10.2005

require 'sprite.rb'

module FreeVikings

  class Penguin < Sprite

    WIDTH = 37
    HEIGHT = 54

    def init_images
      l_imgs = []

      1.upto(3) {|i| l_imgs.push Image.load("penguin_left_#{i}.tga")}

      @image = AnimationSuite.new(0.3, l_imgs) 
    end
  end # class Penguin
end # module FreeVikings
