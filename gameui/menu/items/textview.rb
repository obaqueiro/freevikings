# textview.rb
# igneus 21.7.2009

module GameUI
  module Menus

    # Shows a text (possibly very long, scrollable) an button to close it

    class TextView < Menu

      # Height of box showing text
      SCREEN_H = 380

      # Text can be as long as needed. Newlines should be processed well,
      # other whitespace will be ignored.
      # By default, text will be as wide as the menu normally is. By setting
      # argument text_width you can allow it to be wider or thinner.

      def initialize(parent, title, text, text_width=nil)
        super(parent, title, nil, nil)

        @text_width = text_width or parent.width
        @screens = make_screens text

        # Does the same as QuitButton, but I don't like it's text limited
        # to 'quit' or 'back' here.
        ActionButton.new(self, "OK", Proc.new { self.quit })
      end

      private

      # takes text and "typesets" it on Surfaces; returns them in an Array

      def make_screens(text)
        screens = []
        words_taken_at_once = 15

        while ! text.empty? do
          s = RUDL::Surface.new([@text_width, SCREEN_H])

          text_of_screen = ''


          screens << s
        end

        return screens
      end
    end
  end
end
