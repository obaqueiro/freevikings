# item.rb
# igneus 21.6.2005

=begin
= NAME
Item

= DESCRIPTION
Item is an ((<Entity>)) which can be collected and used (applied)
by the (({Viking})).

= Superclass
Entity
=end

require 'singleton'

module FreeVikings

  class Item < Entity

    WIDTH = 30
    HEIGHT = 30

=begin
= Instance methods

--- Item#apply(user)
Applies the item onto the ((|user|)). ((|user|)) is expected to be 
a ((<Sprite>)). Results of an application can be very different - a change
of weather, some other ((<Entity>))'s death, ...
It returns ((|true|)) if the application is successfull (then the ((<Item>)) 
must be erased from the viking's ((<Inventory>)), ((|false|)) is returned 
otherwise.) 

Example:
An apple which heals the viking who uses it.

class HealingApple < FreeVikings::Item
  def apply(user)
    user.heal
  end
end
=end

    def apply(user)
      true
    end

    def register_in(location)
      location.add_item self
    end
  end # class Item

=begin
= NAME
NullItem

= DESCRIPTION
A Null Object class.
It has only one instance which you can get by call
(({NullItem.instance})).
The standard constructor ((({new}))) is private.

= Superclass
Item
=end

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
