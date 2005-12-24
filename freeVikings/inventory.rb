# inventory.rb
# igneus 21.6.2005

=begin
= NAME
Inventory

= DESCRIPTION
Inventory is a box with four slots. Viking can collect items and put them
into his inventory.
Some basic ideas:
* At most four items can be at once in the inventory.
* When the viking enters a new location, his inventory is emptied.
* There is a special pointer in the inventory. This pointer points onto
  an "active slot" - a slot with an item which is used when the player
  pushes yhe "use key".
* By default, the TAB key allows the player to pause game, go into 
  the inventory and move the pointer; U is a "use key".
* When two vikings are next to each other, they can move items between their
  inventories.
* The "active item" can also be erased from the inventory to make slot free for
  something more important. (In the "Lost Vikings" game this was done by
  moving the item onto an icon of a rubbish bin).
  The erased item doesn't return into the environment, it disappears 
  definitively.
* When the viking passes over an item and there is a free slot in his 
  inventory, the item is collected automatically.

= Superclass
Object
=end

module FreeVikings

  class Inventory

    SLOTS = 4
    MAX_INDEX = SLOTS - 1

    def initialize
      @items = []
      @active_index = 0
    end

    def put(item)
      if full? then
        raise NoSlotFreeException, "There is no free inventory slot " \
        " to place the item #{item} into."
      end
      @items.push item
      @active_index = @items.size - 1
    end

=begin
--- Inventory#erase_active
Removes the active item from the inventory and returns it.
=end

    def erase_active
      item = @items.delete_at @active_index
      if @active_index == @items.size then
        @active_index -= 1 unless @active_index == 0
      end
      return item
    end

    def clear
      @items.clear
    end

    def empty?
      @items.empty?
    end

    def full?
      @items.size >= 4
    end

    def active
      at(@active_index)
    end

    attr_reader :active_index

    def active_index=(i)
      if i > MAX_INDEX then
        raise IndexOutOfBoundsException, "Index #{i} does not point at a valid slot of the inventory."
      end
      unless @items[i]
        raise EmptySlotRequiredException, "Slot #{i} is empty, it cannot be made active."
      end
      @active_index = i
    end

    def first
      at 0
    end

    def second
      at 1
    end

    def third
      at 2
    end

    def fourth
      at 3
    end

    def each
      @items.each {|i| yield i}
    end

    def each_index
      @items.each_index {|i| yield i}
    end

=begin
--- Inventory#at(index)
Returns ((|index|))th item from the ((<Inventory>)) or a (({NullItem})) 
instance if 
=end

    def at(index)
      if index >= SLOTS then
        raise IndexOutOfBoundsException, "Asked for an item in slot #{index}, but the highest slot index is #{SLOTS - 1}"
      end

      if @items[index] then
        return @items[index]
      else
        return NullItem.instance
      end
    end

    def [](index)
      at index
    end

=begin
== Inventory::IndexOutOfBoundsException
This exception is raised by the slot-accessing methods 
(((<Inventory#active_index=>)), ((<Inventory#first>)), ((<Inventory#second>)),
((<Inventory#third>)), ((<Inventory#fourth>)), ((<Inventory#at>)), 
((<Inventory#[]>))) when a non-existing slot is required.
=end
    class IndexOutOfBoundsException < RuntimeError
    end

=begin
== Inventory::NoSlotFreeException
An type of exception raised by ((<Inventory#put>)) if there is no free slot 
in the ((<Inventory>)) to put the Item into.
=end
    class NoSlotFreeException < RuntimeError
    end

=begin
== Inventory::EmptySlotRequiredException
This exception is raised when an attempt is made to access an empty slot.
((<Inventory#active_index=>)) raises it when an empty slot is being made 
active.
=end
    class EmptySlotRequiredException < RuntimeError
    end
  end # class Inventory
end # module FreeVikings
