# menuitem.rb
# igneus 3.8.2005

module GameUI
  module Menus

    # MenuItem is any object which can be put into a Menu.
    # Menu itself is also a MenuItem because the Menus can 
    # (and are intended to) be nested.
    class MenuItem

      # Creates a new ((<MenuItem>)) as a child of ((|parent|)).
      # Remember ((|parent|)) should be a (({Menu})) or any other similar 
      # container.
      def initialize(parent)
        @parent = parent

        unless @parent.nil?
          @parent.add self 
        end
      end

      # Returns the MenuItem's parent or nil if the MenuItem 
      # is a top-level Menu.
      attr_reader :parent

      # Returns a (({RUDL::Surface})) with the ((<MenuItem>))'s image.
      attr_reader :image

      # Returns MenuItem's height (Menu uses this method while repainting
      # itself)
      def height
        @image.h
      end

      # The ((<MenuItem>)) paints itself onto the surface ((|surface|)).
      def paint(surface, coordinates)
        surface.blit image, coordinates
      end

      # This method is called when a left arrow key is pressed over the 
      # MenuItem. By default this method does nothing.
      def less
      end

      # This method is called when a right arrow key is pressed over the 
      # MenuItem. By default this method does nothing.
      def more
      end

      # This method is called when an ENTER key is pressed over the 
      # MenuItem. By default this method does nothing.
      def enter
      end

      # Menu uses this method to tell it's member objects, MenuItems,
      # that it's going to run. MenuItems can use it to reload default 
      # values etc.
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
