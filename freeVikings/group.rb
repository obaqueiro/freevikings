# group.rb
# igneus 19.6.2005

=begin
= NAME
Group

= DESCRIPTION
Superclass for all the "group classes". Everything which has methods add,
delete and include? is a (({Group})). 
The most important subclasses:
* (({SpriteManager}))
* (({Team}))
* (({ItemManager}))
* (({ActiveObjectManager}))

= Superclass
Object
=end

module FreeVikings

  class Group

=begin
= Class methods

--- Group.new
Creates a new (({Group})).
=end

    def initialize
      @members = Array.new
    end

=begin
= Instance methods

--- Group#add(object)
Adds ((|object|)) into the (({Group})).
=end

    def add(object)
      @members.push object
    end

=begin
--- Group#delete(member)
Deletes ((|member|)) from the (({Group})) if it is a member of the (({Group})).
=end

    def delete(member)
      @members.delete member
    end

=begin
--- Group#include?(object)
Says if ((|object|)) is a member of the (({Group})).
=end

    def include?(object)
      @members.include? object
    end

=begin
--- Group#members_on_rect(rect)
Returns an (({Array})) of all the (({Group}))'s members whose
rects collide with (({Rectangle})) ((|rect|)).
=end

    def members_on_rect(rect)
      @members.find_all { |member| rect.collides? member.rect }
    end

=begin
--- Group#each
Iterates over the members and yields every of them.
=end

    def each
      @members.each {|m| yield m}
    end

=begin
--- Group#members
Returns a copy of an (({Array})) with the members.
=end

    def members
      @members.dup
    end

=begin
--- Group#paint(surface, rect_of_location)
((|surface|)) must be (({RUDL::Surface})), ((|rect_of_location|)) should
be a (({Rectangle})).
Paints onto ((|surface|)) all the (({Group}))'s members.
The ((|surface|)) is thought as a view of a part of an area in which 
the members exist and the ((|surface|))'s top-left corner is
thought as the view's top-left corner.

You don't understand it, do you?
=end

    def paint(surface, rect_of_location)
      locr = rect_of_location
      @members.each { |member|
        if member.rect.collides? rect_of_location then
          relative_left = member.rect.left - rect_of_location[0]
          relative_top = member.rect.top - rect_of_location[1]
          surface.blit(member.image, [relative_left, relative_top])
        end
      }
    end
  end # class Group
end # module FreeVikings
