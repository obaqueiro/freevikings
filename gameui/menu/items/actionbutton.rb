# actionbutton.rb
# igneus 3.9.2005

module GameUI
  module Menus

    class ActionButton < SelectableLabel

      def initialize(parent, text, action)
        super(parent, text)
        @action = action
      end

      def enter
        @action.call
      end
    end
  end
end
