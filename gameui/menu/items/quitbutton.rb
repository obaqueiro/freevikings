# quitbutton.rb
# igneus 3.9.2005

=begin
=GameUI::Menus::QuitButton
(({MenuItem})) which gives control to the upper-level (({Menu})) or exits
the game when ENTER is pressed over it.
=end

module GameUI
  module Menus

    class QuitButton < MenuItem

=begin
--- QuitButton::BACK
--- QuitButton::QUIT
--- QuitButton::AUTO
=end
      BACK = 1
      QUIT = 2
      AUTO = 3

=begin
--- QuitButton.new(parent, mode=AUTO)
Argument ((|mode|)) says what sort of text should the ((<QuitButton>)) use.
It must be one of ((<QuitButton::BACK>)), ((<QuitButton::QUIT>)) or
((<QuitButton::AUTO>)).
If it is ((<QuitButton::AUTO>)), it uses QUIT mode inside a top-level 
(({Menu})), BACK mode otherwise.
=end
      
      def initialize(parent, mode=AUTO)
        super(parent)

        if mode == BACK
          title = "Back"
        elsif mode == QUIT
          title = "Quit"
        else
          title = parent.parent ? "Back" : "Quit"
        end

        @image = create_image title
      end

      def enter
        @parent.quit
      end
    end
  end
end
