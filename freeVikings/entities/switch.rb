# switch.rb
# igneus 9.6.2005

require 'monster.rb'

module FreeVikings

  # You can switch it by up/down direction key with a viking standing next to 
  # it or with keys S/F or using Baleog's sword or arrow.

  class Switch < ActiveObject

    # Must be a Monster so that arrow and sword hit it.
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

      @image = Model.new(images)
    end

    attr_reader :state
    attr_accessor :action

    def activate(who=nil)
      switch
    end

    def deactivate(who=nil)
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

    private

    def switch
      @state = (not @state)
      @action.call(@state)
    end
  end # class Switch
end # module FreeVikings
