# bottompanel.rb
# igneus 25.6.2005

=begin
= BottomPanel
BottomPanel is what you can see on the bottom of the game window
during the game. It displays vikings' faces, energy and contents of their 
inventories.
=end

require 'observer'

require 'bottompanelstate.rb'
require 'inventoryview.rb'

module FreeVikings

  class BottomPanel

=begin
Class ((<BottomPanel>)) includes mixin (({Observable})) (a part of Ruby's
standard library). It notifies all observers whenever it's internal
state changes. A (({BottomPanelState})) instance is always sent to them.
=end

    include Observable


    ACTIVE_SELECTION_BLINK_DELAY = 1

    VIKING_FACE_SIZE = 60
    LIVE_SIZE = 20
    ITEM_SIZE = 30
    INVENTORY_VIEW_SIZE = 2 * ITEM_SIZE

    HEIGHT = VIKING_FACE_SIZE + LIVE_SIZE
    WIDTH = 640

=begin
--- BottomPanel.new(team)
Argument ((|team|)) is a Team of heroes who will be displayed on the panel.
=end

    def initialize(team)
      @team = team
      @image = RUDL::Surface.new [WIDTH, HEIGHT]

      init_gfx

      @inventory_views = {}
      @team.each {|v| @inventory_views[v] = InventoryView.new(v, self)}

      change_state NormalBottomPanelState.new(@team)
    end

=begin
--- BottomPanel#set_browse_inventory

=end

    def set_browse_inventory
      if @state.normal? then
        change_state InventoryBrowsingBottomPanelState.new(@team)
      elsif @state.inventory_browsing?
        change_state NormalBottomPanelState.new(@team)
      end

      return @state
    end

    def set_items_exchange
      if @state.inventory_browsing? then
        change_state ItemsExchangeBottomPanelState.new(@team)
      elsif @state.items_exchange?
        change_state InventoryBrowsingBottomPanelState.new(@team)
      end

      return @state
    end

    def delete_active_item
      @state.delete_active_item
    end

    def up
      @state.up
    end

    def down
      @state.down
    end

    def left
      @state.left
    end

    def right
      @state.right
    end

    def mouseclick(pos)
      x = pos[0]
      y = pos[1]

      if i = spot_inside_portrait(*pos) then
        @team.active = @team[i]
      elsif a = spot_inside_item(*pos) then
        viking = @team[a[0]]

        begin
          viking.inventory.active_index = a[1]
        rescue Inventory::EmptySlotRequiredException
          # The exception is just informative. We know it can appear
          # here and nothing dangerous can occur when we pretend
          # we can't see it.
        end

      end
    end

=begin
--- BotomPanel#paint(surface)
Paints itself onto the ((|surface|)). Doesn't worry about the ((|surface|))'s
size.
=end

    def paint(surface)
      # vybarveni pozadi pro podobenky vikingu:
      surface.fill([60,60,60])

      i = 0

      @team.each { |vik|
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
          live_position = [face_position[0] + j * LIVE_SIZE, lives_y]
          surface.blit(@energy_punkt, live_position)
        }

        # paint inventory contents:
        inventory_view_pos = [(i * (INVENTORY_VIEW_SIZE + VIKING_FACE_SIZE)) + INVENTORY_VIEW_SIZE, 0]
        @inventory_views[vik].paint(surface, 
                                    inventory_view_pos, 
                                    (@team.active == vik))

	i += 1
      }
    end

=begin
--- BottomPanel#image
Returns a RUDL::Surface with a updated contents of self.
=end

    def image
      paint(@image)
      @image
    end

    private

    def init_gfx
      @face_bg = RUDL::Surface.load_new(GFX_DIR+'/face_bg.tga')
      @energy_punkt = RUDL::Surface.load_new(GFX_DIR+'/energypunkt.tga')
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
