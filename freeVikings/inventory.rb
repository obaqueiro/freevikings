# inventory.rb
# igneus 21.6.2005

module FreeVikings

=begin
= Inventory
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
  The erased item doesn't return into the environment, id disappears 
  definitively.
* When the viking passes over an item and there is a free slot in his 
  inventory, the item is collected automatically.
=end

  class Inventory

    SLOTS = 4
    MAX_INDEX = SLOTS - 1

    def initialize
      @items = []
      @active_index = 0
    end

    def put(item)
      @items.push item unless full?
    end

    def erase_active
      @items.delete_at @active_index
    end

    def empty?
      @items.empty?
    end

    def full?
      @items.size >= 4
    end

    def active
      @items[@active_index]
    end

    attr_reader :active_index

    def active_index=(i)
      if i > MAX_INDEX then
        raise IndexOutOfBoundsException, "Index #{i} does not point at a valid slot of the inventory."
      end
      @active_index = i
    end

    def first
      @items[0]
    end

    def second
      @items[1]
    end

    def third
      @items[2]
    end

    def fourth
      @items[3]
    end

    def each
      @items.each {|i| yield i}
    end

    def each_index
      @items.each_index {|i| yield i}
    end

    def [](index)
      @items[index]
    end

    class IndexOutOfBoundsException < RuntimeError
    end
  end # class Inventory
end # module FreeVikings
