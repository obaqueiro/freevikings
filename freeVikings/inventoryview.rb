# inventoryview.rb
# igneus 1.8.2005

=begin
= InventoryView
((<InventoryView>)) is one component of the (({BottomPanel})).
It displays contents of some (({Viking}))'s (({Inventory})).
=end

require 'RUDL'

module FreeVikings

  class InventoryView

=begin
--- InventoryView::ITEM_SIZE
Size of a square to display one (({Inventory})) slot's contents.
=end

    ITEM_SIZE = 30

=begin
--- InventoryView::INVENTORY_VIEW_SIZE
Size of a square to display all the (({Inventory})) slots' contents.
=end

    INVENTORY_VIEW_SIZE = 2 * ITEM_SIZE

=begin
--- InventoryView::ACTIVE_SELECTION_BLINK_DELAY
=end

    ACTIVE_SELECTION_BLINK_DELAY = 1

=begin
--- InventoryView.new(inventory_owner, bottompanel)
As arguments accepts the owner of the displayed (({Inventory})) (it is usually
a (({Viking})); the (({Inventory})) is obtained by call to the owner's
'inventory' method) and a (({BottomPanel})) which will use this
((<InventoryView>)).

Initialization has one side effect. The new ((<InventoryView>)) subscribes
as an (({Observer})) to the (({BottomPanel})) ((|bottompanel|)).
It's important for a good work of the ((<InventoryView>)),
because the (({BottomPanel})) informs it's (({Observer}))s about
it's state.
=end

    def initialize(inventory_owner, bottompanel)
      @inventory_owner = inventory_owner
      @inventory = @inventory_owner.inventory

      init_gfx

      # InventoryView wants to know everything about the BottomPanel's
      # state changes, because they influence e.g. type of the
      # selection box displayed
      bottompanel.add_observer self
    end

=begin
--- InventoryView#update(bottompanel_state)
(({BottomPanel})) calls this method to inform the ((<InventoryView>)) that
the state has changed and type of the selection box should be changed
immediately.
Argument ((|bottompanel_state|)) is always a (({BottomPanelState}))
instance.
=end

    def update(bottompanel_state)
      @state = bottompanel_state
    end

=begin
--- InventoryView#paint(surface, position, active)
Paints itself onto (({RUDL::Surface})) ((|surface|)).
Argument ((|position|)) is an (({Array})) [x,y].
((|active|)) is (({Boolean})) and says if the (({Viking})) whose
(({Inventory})) is displayed is active.
=end

    def paint(surface, position, active)
      @active = active
      repaint_image
      surface.blit(@image, position)
    end

    private

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
