# switch.rb
# igneus 9.6.2005

# Prepinac

require 'monster.rb'

module FreeVikings

  class Switch < Sprite

    include Monster

    def initialize(position, on=false, action=nil, images=nil)
      super position
      @state = on

      unless images
        images = {
          'true' => Image.new('switch_green.tga'),
          'false' => Image.new('switch_red.tga')
        }
      end

      @image = ImageBank.new(self, images)
      @action = action
      @rect = Rectangle.new(position[0], position[1], image.w + 40, image.h)
    end

    attr_reader :state
    attr_accessor :action

    def hurt
      switch
    end

    def on?
      @state
    end

    def off?
      not @state
    end

    private

    def switch
      @state = (not @state)
      @action.call(@state) if @action.kind_of? Proc
    end
  end # class Switch
end # module FreeVikings
