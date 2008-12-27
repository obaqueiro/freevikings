# present.rb
# igneus 26.12.2008

module FreeVikings

  # Superclass of other present classes.

  class Present < Item
    def init_images
      @image = Image.load 'presentbox.png'
    end
  end

  # Present which, when used, gives the user another item

  class ItemPresent < Present

    def initialize(position, given_item)
      super(position)
      @given_item = given_item
    end

    def apply(who)
      begin
        who.inventory.put @given_item

        # After successfull application of item viking erases it;
        # but newly added item is automatically set active and viking
        # thinks that active item is the used item, so we have to set
        # the active index to point to the Present and not to the given item.
        i = who.inventory.each_index {|j| 
          if who.inventory[j].object_id == self.object_id then
            break j
          end
        }
        who.inventory.active_index = i

        return true
      rescue Inventory::NoSlotFreeException
        # viking's inventory is full, he can't receive another item -
        # let's place it next to him:
        @given_item.rect.left = who.rect.center[0]
        @given_item.rect.top = who.rect.center[1]
        who.location << @given_item

        return true
      end
    end
  end

  # Present which, when used, performs some action 
  # (usually creates some evil monsters... :) ).
  # Action is a Proc - it may accept one argument: viking who used
  # ('unpacked') the Present.

  class ActionPresent < Present

    def initialize(position, action=Proc.new {})
      super(position)
      @action = action
    end

    def apply(who)
      @action.call(who)
    end
  end
end
