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

    # action should be a Proc (or object which listens to message 'call')
    # and receive up to 2 arguments: first one is Boolean and announces
    # Switche's new state (true = on, false = off), second argument
    # is Switch itself (useful sometimes)

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
      if @action.arity == 1 then
        @action.call(@state)
      elsif @action.arity == 2 then
        @action.call(@state,self)
      elsif @action.arity == 0 then
        @action.call
      else
        # Error may be raised or something...
        @action.call(@state,self)
      end 
    end
  end # class Switch
end # module FreeVikings
