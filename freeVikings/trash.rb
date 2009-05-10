# trash.rb
# igneus 31.10.2008

module FreeVikings

  class BottomPanel

    # Part of BottomPanel. Place where items which should be deleted
    # may be given.
    # Behaves as a "viking" in order to be able to exchange items with vikings.

    class Trash

      WIDTH = HEIGHT = 30

      DUMP_ANIMATION_TIME = 2 # in seconds

      def initialize(position)
        sst = SpriteSheet.load2('panel/trash.png', 30, 30, [1,2,3,4])
        @static_image = sst[1]
        @dump_animation = Animation.new(0.25, [sst[1], sst[2], sst[3], sst[4]])
        @background = Image.load('panel/trash_background.png')

        @rect = Rectangle.new position[0], position[1], WIDTH, HEIGHT
        @inventory = TrashInventory.new
        @highlighted = false

        # Says if some item has been dumped recently
        @dump_anim_lock = TimeLock.new 0
        # Says if last painted image was the 'normal' one
        @last_painted_static = false
      end

      attr_reader :inventory
      attr_reader :rect

      def image
        if @dump_anim_lock.free? then
          @last_painted_static = true
          return @static_image.image
        else
          @last_painted_static = false
          return @dump_animation.image
        end
      end

      # BottomPanel uses this method to check if Trash needs to be repainted

      def need_update?
        (! @dump_anim_lock.free?) || (! @last_painted_static)
      end

      # removes item from inventory

      def dump
        if @inventory.content != nil then
          @dump_anim_lock = TimeLock.new DUMP_ANIMATION_TIME
          @inventory.erase_active
        end
      end

      def alive?
        true
      end

      def paint(surface)
        if @highlighted then
          surface.fill VikingView::HIGHLIGHT_COLOUR, @rect.to_a
        end
        surface.blit @background.image, @rect.top_left
        surface.blit image, @rect.top_left
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
