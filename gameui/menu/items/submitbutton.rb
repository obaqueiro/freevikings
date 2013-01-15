# submitbutton.rb
# igneus 16.8.2008 (but the code is from September 2005)

module GameUI
  module Menus

    # Button, which, when pushed, calls method 'submit'
    # of the parent Menu
    class SubmitButton < MenuItem

      def initialize(parent)
        super(parent)
        @value = 'OK'
        @image = create_image(@value)
      end

      attr_reader :value

      def enter
        @parent.submit
      end
    end
  end
end
