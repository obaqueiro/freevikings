# menuitem.rb
# igneus 3.8.2005

=begin
= GameUI::Menus::MenuItem
((<MenuItem>)) is any object which can be put into a (({Menu})).
(({Menu})) itself is also a (({MenuItem})) because the (({Menu}))s can 
(and are intended to) be nested.
=end

module GameUI
  module Menus

    class MenuItem

=begin
--- MenuItem.new(parent)
Creates a new ((<MenuItem>)) as a child of ((|parent|)).
Remember ((|parent|)) should be a (({Menu})) or any other similar container.
=end

      def initialize(parent)
        @parent = parent

        unless @parent.nil?
          @parent.add self 
        end
      end

=begin
--- MenuItem#parent
Returns the ((<MenuItem>))'s parent or ((|nil|)) if the ((<MenuItem>)) is 
a top-level (({Menu})).
=end

      attr_reader :parent

=begin
--- MenuItem#image
Returns a (({RUDL::Surface})) with the ((<MenuItem>))'s image.
=end

      attr_reader :image

=begin
--- MenuItem#paint(surface, coordinates)
The ((<MenuItem>)) paints itself onto the surface ((|surface|)).
=end

      def paint(surface, coordinates)
        surface.blit image, coordinates
      end

=begin
--- MenuItem#less
This method is called when a left arrow key is pressed over the ((<MenuItem>)).
By default this method does nothing.
=end

      def less
      end

=begin
--- MenuItem#more
This method is called when a right arrow key is pressed over the 
((<MenuItem>)). By default this method does nothing.
=end

      def more
      end

=begin
--- MenuItem#enter
This method is called when an ENTER key is pressed over the 
((<MenuItem>)). By default this method does nothing.
=end

      def enter
      end

=begin
--- MenuItem#prepare
(({Menu})) uses this method to tell it's member objects, ((<MenuItem>))s,
that it's going to run.
((<MenuItem>))s can use it to reload default values etc.
=end

      def prepare
      end

      private

      # renders the text simply

      def create_image(text)
        @parent.text_renderer.create_text_box(@parent.width, text)
      end
    end # class MenuItem
  end # module Menus
end # module GameUI
