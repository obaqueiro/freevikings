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

=begin
--- Item#apply(user)
Applies the item onto the ((|user|)). ((|user|)) is expected to be 
a ((<Sprite>)). Results of an application can be very different - a change
of weather, some other ((<Entity>))'s death, ...
It returns ((|true|)) if the application is successfull (then the ((<Item>)) 
can be erased from the viking's ((<Inventory>)), ((|false|)) is returned 
otherwise.)
=end

    def apply(user)
      true
    end
  end # class Item

  class NullItem < Item
    include Singleton

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
