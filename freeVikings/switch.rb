# switch.rb
# igneus 9.6.2005

# Prepinac

require 'monster.rb'

module FreeVikings

  class Switch < ActiveObject

    include Monster

    WIDTH = 30
    HEIGHT = 30

    def initialize(position, theme, on=false, action=Proc.new {})
      super(position, theme)
      @state = on
      @action = action
      @rect = Rectangle.new(position[0], position[1], WIDTH, HEIGHT)

      images = {
        'true' => get_theme_image('switch_on'),
        'false' => get_theme_image('switch_off')
      }

      @image = Model.new(self, images)
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
