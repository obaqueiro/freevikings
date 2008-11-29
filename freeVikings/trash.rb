# trash.rb
# igneus 31.10.2008

module FreeVikings

  class BottomPanel

    # Part of BottomPanel. Place where items which should be deleted
    # may be given.
    # Behaves as a "viking" in order to be able to exchange items with vikings.

    class Trash

      def initialize(position)
        @image = Image.load 'trash.png'
        @rect = Rectangle.new position[0], position[1], @image.w, @image.h
        @inventory = TrashInventory.new
        @highlighted = false
      end

      attr_reader :image
      attr_reader :inventory
      attr_reader :rect

      # removes item from inventory

      def dump
        @inventory.erase_active
      end

      def alive?
        true
      end

      def paint(surface)
        if @highlighted then
          surface.fill VikingView::HIGHLIGHT_COLOUR, @rect.to_a
        end
        surface.blit @image.image, @rect.top_left
        if @inventory.content then
          surface.blit @inventory.content.image, @rect.top_left
        end
      end

      def highlight
        @highlighted = true
      end

      def unhighlight
        @highlighted = false
      end

      private

      # Pseudo-Inventory which supports just basic set of methods

      class TrashInventory
        def initialize
          @slot = nil
        end

        def erase_active
          o = (@slot or NullItem.instance)
          @slot = nil
          return o
        end

        def put(o)
          @slot = o
        end

        def num_slots
          1
        end

        def active_index
          0
        end

        def content
          @slot
        end

        def full?
          false
        end

        def [](i)
          raise ArgumentError if i > 0
          @slot or NullItem.instance
        end
      end
    end
  end
end
