# trash.rb
# igneus 31.10.2008

module FreeVikings

  # Part of BottomPanel. Place where items which should be deleted
  # may be given.
  # Behaves as a "viking" in order to be able to exchange items with vikings.

  class Trash

    def initialize
      @image = Image.load 'trash.png'
      @portrait = MockPortrait.new @image.image
      @inventory = TrashInventory.new
    end

    attr_reader :portrait
    attr_reader :inventory

    # removes item from inventory

    def dump
      @inventory.erase_active
    end

    # just to behave like a viking

    def alive?
      true
    end

    # Methods rect and collides? to behave like a viking and his Rect

    def rect
      self
    end

    def collides?(rect)
      true
    end

    private

    class MockPortrait < Struct.new(:active, :unactive)
      def initialize(img)
        self.active = self.unactive = img
      end
    end

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
