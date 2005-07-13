# switch.rb
# igneus 9.6.2005

# Prepinac

require 'activeobject.rb'
require 'monster.rb'

module FreeVikings

  class Switch < ActiveObject

    include Monster

    WIDTH = 30
    HEIGHT = 30

    def initialize(position, on=false, action=Proc.new {}, images=nil)
      super position
      @state = on
      @rect = Rectangle.new(position[0], position[1], WIDTH, HEIGHT)

      unless images
        images = {
          'true' => Image.load('switch_green.tga'),
          'false' => Image.load('switch_red.tga')
        }
      end

      @image = ImageBank.new(self, images)
      @action = action
    end

    attr_reader :state
    attr_accessor :action

    def activate
      switch
    end

    def deactivate
      switch
    end

    def hurt
      switch
    end

    def on?
      @state
    end

    def off?
      not @state
    end

    def image
      @image.image
    end

    private

    def switch
      @state = (not @state)
      @action.call(@state)
    end
  end # class Switch
end # module FreeVikings
