# bottompanel.rb
# igneus 25.6.2005

require 'observer'
require 'forwardable'

require 'bottompanelstate.rb'
require 'inventoryview.rb'

module FreeVikings

  # BottomPanel is what you can see on the bottom of the game window
  # during the game. It displays vikings' faces, energy and contents of their 
  # inventories.

  class BottomPanel

    # Class BottomPanel includes mixin Observable (a part of Ruby's
    # standard library). It notifies all observers whenever it's internal
    # state changes. A BottomPanelState instance is always sent to them.

    include Observable


    ACTIVE_SELECTION_BLINK_DELAY = 1

    VIKING_FACE_SIZE = 60
    LIFE_SIZE = 20
    ITEM_SIZE = 30
    INVENTORY_VIEW_SIZE = 2 * ITEM_SIZE

    HEIGHT = VIKING_FACE_SIZE + LIFE_SIZE
    WIDTH = 640

    # Argument team is a Team of heroes who will be displayed on the panel.

    def initialize(team)
      @team = team
      @image = RUDL::Surface.new [WIDTH, HEIGHT]

      init_gfx

      @inventory_views = {}
      @team.each {|v| @inventory_views[v] = InventoryView.new(v, self)}

      change_state NormalBottomPanelState.new(@team)
    end

    extend Forwardable

    # The BottomPanel turns to inventory browsing mode in which
    # it is posible to move the selection box around the inventory of the 
    # active team-member.

    def browse_inventory!
      change_state InventoryBrowsingBottomPanelState.new(@team)
    end

    def_delegator :@state, :inventory_browsing?

    # The BottomPanel turns to item-exchange mode in which it is possible
    # to exchange items between team-members who are close enough 
    # to each other.

    def exchange_items!
      change_state ItemsExchangeBottomPanelState.new(@team)
    end

    def_delegator :@state, :items_exchange?

    # The BottomPanel turns off inventory browsing/item-exchange mode
    # and goes the default way.

    def go_normal!
      change_state NormalBottomPanelState.new(@team)
    end

    def_delegator :@state, :normal?

    # These methods' behavior strongly depends on the BottomPanel's state.

    def_delegator :@state, :delete_active_item
    def_delegator :@state, :up
    def_delegator :@state, :down
    def_delegator :@state, :left
    def_delegator :@state, :right

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
        @last_clicked_item = item_index
        @last_clicked_viking = viking_index

        begin
          @team[viking_index].inventory.active_index = item_index
        rescue Inventory::EmptySlotRequiredException
          # The exception is just informative. We know it can appear
          # here and nothing dangerous can occur when we pretend
          # we can't see it.
        end

      end
    end

    # About pos see documentation of method mouseclick.
    def mouserelease(pos)
      if a = spot_inside_item(*pos) || b = spot_inside_portrait(*pos) then
        if a then
          viking_index, item_index = a
        else
          viking_index = b
        end
        if @last_clicked_viking != nil && viking_index != @last_clicked_viking then
          source_viking = @team[@last_clicked_viking]
          dest_viking = @team[viking_index]
          if source_viking.rect.collides?(dest_viking.rect) &&
              ! dest_viking.inventory.full? then
            source_viking.inventory.active_index = @last_clicked_item
            dest_viking.inventory.put(source_viking.inventory.erase_active)
          end
        end
      end
      @last_clicked_viking = nil
      @last_clicked_item = nil
    end

    # Paints itself onto the surface. Doesn't worry about the surface's
    # size!

    def paint(surface)
      surface.fill([60,60,60])

      @team.each_with_index do |vik, i|
        # paint face:
        face_position = [i * (INVENTORY_VIEW_SIZE + VIKING_FACE_SIZE), 0]
	surface.blit(@face_bg, face_position)
        portrait_img = if @team.active == vik && vik.alive? then
                         vik.portrait.active
                       elsif not vik.alive?
                         vik.portrait.kaput
                       else
                         vik.portrait.unactive
                       end
        surface.blit(portrait_img, face_position)

        # paint the lives:
        lives_y = VIKING_FACE_SIZE
        vik.energy.times {|j| 
          live_position = [face_position[0] + j * LIFE_SIZE, lives_y]
          surface.blit(@energy_punkt, live_position)
        }

        # paint inventory contents:
        inventory_view_pos = [(i * (INVENTORY_VIEW_SIZE + VIKING_FACE_SIZE)) + INVENTORY_VIEW_SIZE, 0]
        show_off = items_exchange? && 
          vik != @team.active && 
          ((! vik.rect.collides?(@team.active.rect)) || vik.inventory.full?)

        @inventory_views[vik].paint(surface, 
                                    inventory_view_pos, 
                                    (@team.active == vik),
                                    show_off)
      end
    end

    # Returns a RUDL::Surface with updated contents of self.

    def image
      paint(@image)
      @image
    end

    private

    def init_gfx
      @face_bg = RUDL::Surface.load_new(GFX_DIR+'/face_bg.tga')
      @energy_punkt = RUDL::Surface.load_new(GFX_DIR+'/energypunkt.png')
    end # init_display

    # If the point defined by coordinates x,y is inside some
    # viking's portrait, returns the viking's index in the team.
    # Otherwise nil is returned.

    def spot_inside_portrait(x, y)
      if (y < VIKING_FACE_SIZE) and
          (x % (VIKING_FACE_SIZE + INVENTORY_VIEW_SIZE)) < VIKING_FACE_SIZE then
        viking_index = x / (VIKING_FACE_SIZE + INVENTORY_VIEW_SIZE)
        return viking_index if viking_index < @team.size
      end
      return nil
    end

    # If the point defined by coordinates x,y is inside some
    # item's image, an Array [viking_index, item_index] is returned.
    # Otherwise nil is returned.

    def spot_inside_item(x, y)
      if (y < INVENTORY_VIEW_SIZE) and
          (x % (VIKING_FACE_SIZE + INVENTORY_VIEW_SIZE)) > VIKING_FACE_SIZE then
        x_in_view = x % INVENTORY_VIEW_SIZE
        y_in_view = y % INVENTORY_VIEW_SIZE

        viking_index = x / (VIKING_FACE_SIZE + INVENTORY_VIEW_SIZE)
        item_index = if x_in_view >= ITEM_SIZE and y_in_view >= ITEM_SIZE then
                       3
                     elsif y_in_view >= ITEM_SIZE then
                       2
                     elsif x_in_view >= ITEM_SIZE then
                       1
                     elsif x_in_view <= ITEM_SIZE and y_in_view <= ITEM_SIZE then
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
      changed
      notify_observers(@state)
    end

  end # class BottomPanel
end # module FreeVikings
