# bottompanelstate.rb
# igneus 23.7.2005

# Well, after some applications in the freeVikings project, I do really hate
# the State design pattern. But I do also hate code replication and
# long if-expressions, so I decided to use this pattern in BottomPanel.
# Ugh!

module FreeVikings

  class BottomPanelState

    def initialize(team)
      @team = team
    end

    def up
    end

    def down
    end

    def left
    end

    def right
    end

    def delete_active_item
    end

    def normal?
      false
    end

    def inventory_browsing?
      false
    end

    def items_exchange?
      false
    end

    private

    def active_inventory
      @team.active.inventory
    end

  end # class BottomPanelState


  # From NormalBottomPanelState you can switch 
  # to InventoryBrowsingBottomPanelState (in the game by the TAB key),
  # from this to ItemsExchangeBottomPanelState. And back again.
  # The switching mechanism is built in the BottomPanel class.

  class NormalBottomPanelState < BottomPanelState

    def normal?
      true
    end
  end


  class InventoryBrowsingBottomPanelState < BottomPanelState

    def up
      if active_inventory.active_index >= 2 then
        active_inventory.active_index -= 2
      end
    end

    def down
      if active_inventory.active_index <= 1 then
        active_inventory.active_index += 2
      end
    end

    def left
      if active_inventory.active_index % 2 == 1 then
        active_inventory.active_index -= 1
      end
    end

    def right
      if active_inventory.active_index % 2 == 0 then
        active_inventory.active_index += 1
      end
    end

    def delete_active_item
      @team.active.inventory.erase_active
    end

    def inventory_browsing?
      true
    end
  end


  class ItemsExchangeBottomPanelState < BottomPanelState

    def initialize(team, trash)
      super(team)
      # A temporary Team containing only the vikings which participate
      # on the items exchange:
      @exchange_participants = Team.new(*(@team.members_on_rect(@team.active.rect) << trash))
      # We need the active member of the original team (stored in variable
      # @team) to be also an active member of the @exchange_participants Team
      while @exchange_participants.active != @team.active do
        @exchange_participants.next
      end
    end

    def items_exchange?
      true
    end

    def left
      move_selected_item(:previous)
    end

    def right
      move_selected_item(:next)
    end

    private

    def move_selected_item(methodname)
      exchanged_item = @exchange_participants.active.inventory.erase_active

      begin
        @exchange_participants.send(methodname)
        @exchange_participants.active.inventory.put exchanged_item
      rescue Inventory::NoSlotFreeException
        # The destination inventory is full.
        # We must switch to another viking and give the item to him.
        retry
      end

      @team.active = @exchange_participants.active
    end
  end
end # module FreeVikings
