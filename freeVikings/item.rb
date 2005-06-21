# item.rb
# igneus 21.6.2005

require 'entity.rb'

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
=end

    def apply(user)
    end
  end # class Item
end # module FreeVikings
