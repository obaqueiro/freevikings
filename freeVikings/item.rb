# item.rb
# igneus 21.6.2005

require 'entity.rb'
require 'singleton'

module FreeVikings

=begin
= Item
Item is an ((<Entity>)) which can be collected.
It supports one operation - application (see ((<Item#apply>))).
=end

  class Item < Entity

    WIDTH = 30
    HEIGHT = 30

=begin
--- Item#apply(user)
Applies the item onto the ((|user|)). ((|user|)) is expected to be 
a ((<Sprite>)). Results of an application can be very different - a change
of weather, some other ((<Entity>))'s death, ...
It returns ((|true|)) if the application is successfull (then the ((<Item>)) 
must be erased from the viking's ((<Inventory>)), ((|false|)) is returned 
otherwise.) 
=end

    def apply(user)
      true
    end
  end # class Item

=begin
= NullItem
((<NullItem>)) is a subclass of ((<Item>)). It represents "no ((<Item>))"
and is used e.g. in an (({Inventory}))
=end

  class NullItem < Item

    include Singleton

=begin
--- NullItem.instance
Returns a ((<NullItem>)) instance. Yes, you are right. ((<NullItem>)) class
implements a Singleton design pattern. (By Ruby's stdlib mechanism.)
=end

    def initialize
      super([0,0,0,0])
    end

    def apply(user)
      false
    end

    def null?
      true
    end
  end
end # module FreeVikings
