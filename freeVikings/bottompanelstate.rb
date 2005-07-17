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

    def inventory_browsing?
      true
    end
  end


  class ItemsExchangeBottomPanelState < BottomPanelState

    def items_exchange?
      true
    end
  end
end # module FreeVikings
