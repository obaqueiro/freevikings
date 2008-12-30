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

    extend Forwardable

    # Class BottomPanel includes mixin Observable (a part of Ruby's
    # standard library). It notifies all observers whenever it's internal
    # state changes. A BottomPanelState instance is always sent to them.

    
    SIZES = {
      :horizontal => [640, VikingView::HEIGHT],
      :vertical => [VikingView::WIDTH, 480]
    }

    # Maximum milliseconds between two clicks which are considered to be
    # a double-click
    DOUBLECLICK_MILLIS = 650
    DOUBLECLICK_SECONDS = DOUBLECLICK_MILLIS.to_f / 1000

    # Argument team is a Team of heroes who will be displayed on the panel.
    # Orientation is either :horizontal or :vertical

    def initialize(team, placement=:bottom)
      @team = team

      unless [:top, :bottom, :left, :right].include?(placement) then
        raise ArgumentError, "Unknown placement '#{placement}' (#{placement.class})"
      end

      @placement = placement
      case @placement
      when :bottom
        @orientation = :horizontal
        x = 0
        y = FreeVikings::WIN_HEIGHT-SIZES[:horizontal][1]
      when :top
        @orientation = :horizontal
        x = 0
        y = 0
      when :left
        @orientation = :vertical
        x = 0
        y = 0
      when :right
        @orientation = :vertical
        x = FreeVikings::WIN_WIDTH - SIZES[:vertical][0]
        y = 0
      end

      @rect = Rectangle.new(x,y,*(SIZES[@orientation]))

      # trashe's position is relative to BottomPanel's rectangle,
      # not to application window!
      trash_pos = if @orientation == :vertical then
                    [0, VikingView::HEIGHT*3]
                  else
                    [VikingView::WIDTH*3, 0]
                  end
      @trash = Trash.new trash_pos

      @image = RUDL::Surface.new [@rect.w, @rect.h]

      @viking_views = @viking_views_hash = {}
      @viking_views_array = []
      @team.each_with_index {|v,i|
        pos = if @orientation == :horizontal then
                [i * VikingView::WIDTH, 0]
              else
                [0, i * VikingView::HEIGHT]
              end
        view = VikingView.new(v, pos)

        @viking_views[v] = view
        @viking_views_array << view
      }

      # slot for clicked item (before it is possible to decide if it was just
      # clicked or if it is dragged)
      @clicked_item = nil
      # slot for clicked item (to wait if it won't be clicked soon again -
      # double-clicked)
      @clicked_item_dc = nil
      # time of last click (to determine double-clicks) (aTime.to_f)
      @last_click_time = 0
      # slot for item exchanged by drag-and-drop
      @dragged_item = nil

      change_state NormalBottomPanelState.new(self)

      change_active_viking
      repaint_image
    end

    def width
      @rect.w
    end

    def height
      @rect.h
    end

    # interface for BottomPanelState
    attr_reader :trash
    attr_reader :team

    # interface for Game:
    attr_reader :orientation
    attr_reader :placement
    attr_reader :rect

    # The BottomPanel turns to inventory browsing mode in which
    # it is posible to move the selection box around the inventory of the 
    # active team-member.

    def browse_inventory!
      change_state InventoryBrowsingBottomPanelState.new(self)
      @trash.dump
      unhighlight
    end

    def_delegator :@state, :inventory_browsing?

    # The BottomPanel turns to item-exchange mode in which it is possible
    # to exchange items between team-members who are close enough 
    # to each other.

    def exchange_items!
      # it is impossible to exchange non-existing item...
      if @team.active.inventory.empty? then
        return
      end

      change_state ItemsExchangeBottomPanelState.new(self)

      @team.each {|viking|
        if @state.exchange_participants.include?(viking) then
          @viking_views[viking].highlight
        else
          @viking_views[viking].unhighlight
        end
      }
      @trash.highlight
    end

    def_delegator :@state, :items_exchange?

    # The BottomPanel turns off inventory browsing/item-exchange mode
    # and goes the default way.

    def go_normal!
      change_state NormalBottomPanelState.new(self)
      @trash.dump
      unhighlight
    end

    def_delegator :@state, :normal?

    # These methods' behavior strongly depends on the BottomPanel's state.

    def_delegator :@state, :delete_active_item
    def_delegator :@state, :up
    def_delegator :@state, :down
    def_delegator :@state, :left
    def_delegator :@state, :right

    # Must be called whenever active viking is changed (to ensure that
    # right portrait is highlighted).

    def change_active_viking
      @viking_views_array.each {|view|
        view.deactivate
      }
      @viking_views[@team.active].activate
    end

    private

    # == Private methods which support mouse-driven transactions with items

    DraggedItemWrapper = Struct.new(:item, :owner, :position)

    # Takes some item for drag&drop operation

    def start_drag_item(pos)
      @dragged_item = @clicked_item
      @clicked_item = nil
      @dragged_item.position = pos
      @dragged_item.item = @dragged_item.owner.inventory.erase_active

      exchange_participants = Team.new(* @team.members_on_rect(@team.active.rect))
      @team.each {|viking|
        if exchange_participants.include?(viking) then
          @viking_views[viking].highlight
        else
          @viking_views[viking].unhighlight
        end
      }
      @trash.highlight
    end

    # Moves dragged item to given position

    def drag_item(pos)
      @dragged_item.position = pos
    end

    # Drops the dragged item

    def drop_item(pos)
      if spot_inside_trash(*pos)
        @dragged_item = nil
        repaint_image
        return
      end

      # item isn't dropped into trash; let's try if it's dropped 
      # over some viking
      if @dragged_item then
        view = @viking_views_array.find {|vv| vv.rect.point_inside?(pos) }
        if view then
          dest_viking = view.viking

          if @dragged_item.owner.rect.collides?(dest_viking.rect) &&
              ! dest_viking.inventory.full? then
            # operation succeeded
            dest_viking.inventory.put(@dragged_item.item)
            @dragged_item = nil
            return
          end
        end
      end

      # if exchange was unsuccessfull, cancel it:
      if @dragged_item then
        # Mouse operations don't cause pause, so owner's inventory may be
        # filled during the exchange operation.
        unless @dragged_item.owner.inventory.full?
          @dragged_item.owner.inventory.put @dragged_item.item
        end
        @dragged_item = nil
      end
    end

    public

    # pos is a two-element array (standard [x,y] coordinates as used in RUDL
    # etc.). Remember that [0,0] is the top-left corner of the panel, not 
    # of the game screen!
    #
    # If the position is inside some panel icon (viking face/item), 
    # the viking/item is made active.

    def mouseclick(pos)
      time_now = Time.now.to_f

      if i = spot_inside_portrait(*pos) then
        @team.active = @team[i]
        change_active_viking
      elsif a = spot_inside_item(*pos) then
        viking_index, item_index = a

        # doubleclick?
        if @clicked_item_dc &&
            @team[viking_index] == @clicked_item_dc.owner &&
            item_index == @team[viking_index].inventory.active_index &&
            (time_now - DOUBLECLICK_SECONDS) <= @last_click_time then
          @clicked_item_dc = nil
          @clicked_item = nil
          @team[viking_index].use_item
          return
        end

        @clicked_item_dc = nil

        begin
          @team[viking_index].inventory.active_index = item_index
          @clicked_item = DraggedItemWrapper.new
          @clicked_item.owner = @team[viking_index]
        rescue Inventory::EmptySlotRequiredException
          # No dragging may be done.
          @clicked_item = nil
        end
      end

      @last_click_time = time_now
    end

    # About pos see documentation of method mouseclick.

    def mouserelease(pos)
      if @clicked_item then
        @clicked_item_dc = @clicked_item
        @clicked_item = nil
      end

      unless @dragged_item
        return
      end

      unhighlight

      drop_item pos
    end

    def mousemove(pos)
      if @clicked_item then
        start_drag_item pos
      end
      if @dragged_item then
        drag_item pos
      end
    end

    # Should be called in every frame before first call to BottomPanel#image;
    # updates the image if needed

    def update
      if inventory_browsing? ||
          items_exchange? ||
          @viking_views_array.find {|v| v.need_update? } then
        repaint_image
        @viking_views_array.each {|v| v.updated }
      end
    end

    # Returns a RUDL::Surface with contents of self (without dragged item).

    attr_reader :image

    # Paints itself onto a surface. Paints dragged item (which is not 
    # on BottomPanel#image)

    def paint(surface, position)
      surface.blit @image, position

      if @dragged_item then
        x, y = @dragged_item.position
        img = @dragged_item.item.image
        x -= img.w/2
        y -= img.h/2
        surface.blit img, [position[0]+x, position[1]+y]
      end      
    end

    private

    # Paints itself onto the surface. Doesn't worry about the surface's
    # size!

    def repaint_image
      @image.fill([60,60,60])

      @team.each_with_index do |vik, i|
        @viking_views[vik].paint(@image)
      end

      @trash.paint(@image)
    end

    # If the point defined by coordinates x,y is inside some
    # viking's portrait, returns the viking's index in the team.
    # Otherwise nil is returned.

    def spot_inside_portrait(x, y)
      pos = [x,y]
      view = @viking_views_array.find {|vv| vv.rect.point_inside?(pos) }
      return nil unless view

      if view.pos_in_portrait?(pos) then
        return @viking_views_array.index(view)
      else
        return nil
      end
    end

    def spot_inside_trash(x, y)
      point_rect = [x,y,0,0]
      if @trash.rect.contains?(point_rect) then
        return true
      end
      return nil
    end

    # If the point defined by coordinates x,y is inside some
    # item's image, an Array [viking_index, item_index] is returned.
    # Otherwise nil is returned.

    def spot_inside_item(x, y)
      pos = [x,y]

      view = @viking_views_array.find {|vv| 
        vv.pos_in_inventory?(pos)
      }

      return nil unless view

      i = view.pos_in_item?(pos)
      if i == nil then
        return nil
      else
        return [@viking_views_array.index(view), i]
      end
    end

    STATE_METHODS = {NormalBottomPanelState => :normal,
      InventoryBrowsingBottomPanelState => :browse,
      ItemsExchangeBottomPanelState => :exchange}

    # Changes the state of BottomPanel to new_state

    def change_state(new_state)
      @state = new_state

      @viking_views_array.each {|v|
        set_view_mode_according_to_state v
      }
    end

    def set_view_mode_according_to_state(view)
      method = STATE_METHODS[@state.class]
      view.send method
    end

    def unhighlight
      @viking_views_array.each {|v| v.unhighlight }
      @trash.unhighlight
    end

  end # class BottomPanel
end # module FreeVikings
