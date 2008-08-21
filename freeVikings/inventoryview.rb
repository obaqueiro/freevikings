# inventoryview.rb
# igneus 1.8.2005

require 'RUDL'

module FreeVikings

  # InventoryView is one component of the BottomPanel.
  # It displays contents of some Viking's Inventory.

  class InventoryView


    # Size of a square to display one Inventory slot's contents.
    ITEM_SIZE = 30

    # Size of a square to display all the Inventory slots' contents.
    INVENTORY_VIEW_SIZE = 2 * ITEM_SIZE

    ACTIVE_SELECTION_BLINK_DELAY = 1

    @@dark_filter = nil

    # As arguments accepts the owner of the displayed Inventory (it is usually
    # a Viking; the Inventory is obtained by call to the owner's
    # 'inventory' method) and a BottomPanel which will use this
    # InventoryView.
    #
    # Initialization has one side effect. The new InventoryView subscribes
    # as an Observer to the BottomPanel bottompanel.
    # It's important for a good work of the InventoryView,
    # because the BottomPanel informs it's Observers about
    # it's state.

    def initialize(inventory_owner, bottompanel)
      @inventory_owner = inventory_owner
      @inventory = @inventory_owner.inventory

      init_gfx

      # InventoryView wants to know everything about the BottomPanel's
      # state changes, because they influence e.g. type of the
      # selection box displayed
      bottompanel.add_observer self
    end

    # BottomPanel calls this method to inform the InventoryView that
    # the state has changed and type of the selection box should be changed
    # immediately.
    # Argument bottompanel_state is always a BottomPanelState
    # instance.

    def update(bottompanel_state)
      @state = bottompanel_state
    end

    # Paints itself onto RUDL::Surface surface.
    # Arguments:
    # position:: Array [x,y].
    # active:: Boolean, says if the Viking whose Inventory is displayed is 
    #          active.
    # show_off:: Boolean - if set to <tt>true</tt>, the InventoryView
    #            is painted as inactive. This is only used in "items
    #            exchange mode" for inventories of vikings who cannot
    #            exchange items because they are too distant from the active 
    #            one
    def paint(surface, position, active, show_off=false)
      @active = active
      repaint_image

      if show_off then
        @image.blit InventoryView.dark_filter, [0,0]
      end

      surface.blit(@image, position)
    end

    private

    # returns semi-transparent Surface which is used to darken
    # inactive inventories during items exchange

    def InventoryView.dark_filter
      if @@dark_filter.nil? then
        @@dark_filter = RUDL::Surface.new [INVENTORY_VIEW_SIZE, 
                                           INVENTORY_VIEW_SIZE]
        grey = [15, 15, 15]
        @@dark_filter.fill grey
        @@dark_filter.set_alpha 150
      end

      return @@dark_filter
    end

    # Positions of items in @image
    ITEM_POSITIONS = [[0,0],        [ITEM_SIZE,0],
                      [0,ITEM_SIZE],[ITEM_SIZE, ITEM_SIZE]]


    # Refreshes contents of @image.

    def repaint_image
      @image = RUDL::Surface.new [INVENTORY_VIEW_SIZE, INVENTORY_VIEW_SIZE]

      time = Time.now.to_f

      0.upto(3) do |k|
        item_position = ITEM_POSITIONS[k]

        @image.blit(@item_bg, item_position)

        unless @inventory[k].null?
          @image.blit(@inventory[k].image, item_position)
        end

        if @inventory.active_index == k then
          if show_selection_box? then
            @image.blit(selection_box, item_position)
          end
        end
      end
    end

    # Should the selection box be displayed? (Calculates with blinking.)

    def show_selection_box?
      if @state.normal?
        return true
      end

      unless @active
        return true
      end

      if (@active and 
            (@state.inventory_browsing? or @state.items_exchange?) and 
            (Time.now.to_f % ACTIVE_SELECTION_BLINK_DELAY > 0.2)
       ) then
        return true
      end

    end

    # Returns an image for the current type of selection box.

    def selection_box
      if @state.items_exchange? and @active then
        return @selection_box_green
      else
        return @selection_box_yellow
      end
    end

    # loads the images

    def init_gfx
      @item_bg = RUDL::Surface.load_new(GFX_DIR+'/item_bg.tga')
      @selection_box_yellow = RUDL::Surface.load_new(GFX_DIR+'/selection.tga')
      @selection_box_green = RUDL::Surface.load_new(GFX_DIR+'/selection_exchange.tga')
    end
  end # class InventoryView
end # module FreeVikings
