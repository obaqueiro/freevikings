# bottompanel.rb
# igneus 25.6.2005

require 'observer'
require 'forwardable'

require 'bottompanelstate.rb'
require 'bpvikingview.rb'

require 'trash.rb'

module FreeVikings

  # BottomPanel is what you can see on the bottom of the game window
  # during the game. It displays vikings' faces, energy and contents of their 
  # inventories.

  class BottomPanel

    # Class BottomPanel includes mixin Observable (a part of Ruby's
    # standard library). It notifies all observers whenever it's internal
    # state changes. A BottomPanelState instance is always sent to them.

    WIDTH = 640
    HEIGHT = VikingView::HEIGHT

    # Argument team is a Team of heroes who will be displayed on the panel.

    def initialize(team)
      @team = team
      @trash = Trash.new

      @image = RUDL::Surface.new [WIDTH, HEIGHT]

      @viking_views = {}
      @team.each_with_index {|v,i|
        pos = [i * VikingView::WIDTH, 0]
        @viking_views[v] = VikingView.new(v, pos)
      }

      # slot for item exchanged by drag-and-drop
      @dragged_item = nil

      change_state NormalBottomPanelState.new(@team)
    end

    extend Forwardable

    # The BottomPanel turns to inventory browsing mode in which
    # it is posible to move the selection box around the inventory of the 
    # active team-member.

    def browse_inventory!
      change_state InventoryBrowsingBottomPanelState.new(@team)
      @trash.dump
    end

    def_delegator :@state, :inventory_browsing?

    # The BottomPanel turns to item-exchange mode in which it is possible
    # to exchange items between team-members who are close enough 
    # to each other.

    def exchange_items!
      change_state ItemsExchangeBottomPanelState.new(@team, @trash)
    end

    def_delegator :@state, :items_exchange?

    # The BottomPanel turns off inventory browsing/item-exchange mode
    # and goes the default way.

    def go_normal!
      change_state NormalBottomPanelState.new(@team)
      @trash.dump
    end

    def_delegator :@state, :normal?

    # These methods' behavior strongly depends on the BottomPanel's state.

    def_delegator :@state, :delete_active_item
    def_delegator :@state, :up
    def_delegator :@state, :down
    def_delegator :@state, :left
    def_delegator :@state, :right

    DraggedItemWrapper = Struct.new(:item, :owner, :position)

    # pos is a two-element array (standard [x,y] coordinates as used in RUDL
    # etc.). Remember that [0,0] is the top-left corner of the panel, not 
    # of the game screen!
    #
    # If the position is inside some panel icon (viking face/item), 
    # the viking/item is made active.

    def mouseclick(pos)
      if i = spot_inside_portrait(*pos) then
        @team.active = @team[i]
      elsif a = spot_inside_item(*pos) then
        viking_index, item_index = a

        begin
          @team[viking_index].inventory.active_index = item_index
          @dragged_item = DraggedItemWrapper.new
          @dragged_item.owner = @team[viking_index]
          @dragged_item.item = @dragged_item.owner.inventory.erase_active
          @dragged_item.position = pos
        rescue Inventory::EmptySlotRequiredException
          # No dragging may be done.
          @dragged_item = nil
        end

      end
    end

    # About pos see documentation of method mouseclick.

    def mouserelease(pos)
      if spot_inside_trash(*pos)
        @dragged_item = nil
        return
      end

      if a = spot_inside_item(*pos) || b = spot_inside_portrait(*pos) then
        if a then
          viking_index, item_index = a
        else
          viking_index = b
        end

        if @dragged_item then
          dest_viking = @team[viking_index]

          if @dragged_item.owner.rect.collides?(dest_viking.rect) &&
              ! dest_viking.inventory.full? then
            # operation succeeded
            dest_viking.inventory.put(@dragged_item.item)
            @dragged_item = nil
            return
          end
        end
      end

      # either there was no exchange or exchange is unsuccessfull:
      if @dragged_item then
        @dragged_item.owner.inventory.put @dragged_item.item
        @dragged_item = nil
      end
    end

    def mousemove(pos)
      if @dragged_item then
        @dragged_item.position = pos
      end
    end

    # Paints itself onto the surface. Doesn't worry about the surface's
    # size!

    def paint(surface)
      surface.fill([60,60,60])

      @team.each_with_index do |vik, i|
        @viking_views[vik].paint(surface)
      end

      if @dragged_item then
        x, y = @dragged_item.position
        image = @dragged_item.item.image
        x -= image.w/2
        y -= image.h/2
        surface.blit image, [x,y]
      end
    end

    # Returns a RUDL::Surface with updated contents of self.

    def image
      paint(@image)
      @image
    end

    private

    # If the point defined by coordinates x,y is inside some
    # viking's portrait, returns the viking's index in the team.
    # Otherwise nil is returned.

    def spot_inside_portrait(x, y)
      if (y < VikingView::VIKING_FACE_SIZE) and
          (x % (VikingView::VIKING_FACE_SIZE + VikingView::INVENTORY_VIEW_SIZE)) < VikingView::VIKING_FACE_SIZE then
        viking_index = x / (VikingView::VIKING_FACE_SIZE + VikingView::INVENTORY_VIEW_SIZE)
        return viking_index if viking_index < @team.size
      end
      return nil
    end

    def spot_inside_trash(x, y)
      one_viking_view_size = (VikingView::INVENTORY_VIEW_SIZE + VikingView::VIKING_FACE_SIZE)
      trash_icon_start = 4 * one_viking_view_size
      trash_inventory_end = trash_icon_start + one_viking_view_size

      if (y < VikingView::VIKING_FACE_SIZE) and
          x > trash_icon_start and
          x < trash_inventory_end then
        return true
      end

      return nil
    end

    # If the point defined by coordinates x,y is inside some
    # item's image, an Array [viking_index, item_index] is returned.
    # Otherwise nil is returned.

    def spot_inside_item(x, y)
      if (y < VikingView::INVENTORY_VIEW_SIZE) and
          (x % (VikingView::VIKING_FACE_SIZE + VikingView::INVENTORY_VIEW_SIZE)) > VikingView::VIKING_FACE_SIZE then
        x_in_view = x % VikingView::INVENTORY_VIEW_SIZE
        y_in_view = y % VikingView::INVENTORY_VIEW_SIZE

        viking_index = x / (VikingView::VIKING_FACE_SIZE + VikingView::INVENTORY_VIEW_SIZE)
        item_index = if x_in_view >= VikingView::ITEM_SIZE and y_in_view >= VikingView::ITEM_SIZE then
                       3
                     elsif y_in_view >= VikingView::ITEM_SIZE then
                       2
                     elsif x_in_view >= VikingView::ITEM_SIZE then
                       1
                     elsif x_in_view <= VikingView::ITEM_SIZE and y_in_view <= VikingView::ITEM_SIZE then
                       0
                     end
        return [viking_index, item_index] if viking_index < @team.size
      end
      return nil
    end

    # Changes the state of the BottomPanel to new_state and notifies all 
    # observers about the change

    def change_state(new_state)
      @state = new_state
    end

  end # class BottomPanel
end # module FreeVikings
