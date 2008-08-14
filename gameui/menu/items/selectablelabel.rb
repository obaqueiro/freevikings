# selectablelabel.rb
# igneus 3.9.2005

=begin
= GameUI::Menus::SelectableLabel
The simpliest (({Menu})) item. A label which does nothing, but can be selected
by the selector.
=end

module GameUI
  module Menus

    class SelectableLabel < MenuItem

      def initialize(parent, text)
        super(parent)
        @text = text
        @image = create_image(text)
      end
    end
  end
end
