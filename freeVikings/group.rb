# group.rb
# igneus 19.6.2005

# Superclass for all the "group classes". Everything which has methods add, 
# delete and include? is a Group.

module FreeVikings

  class Group

    def initialize
      @members = Array.new
    end

    def add(object)
      @members.push object
    end

    def delete(member)
      @members.delete member
    end

    def include?(object)
      @members.include? object
    end

    def members_on_rect(rect)
      @members.find_all { |member| rect.collides? member.rect }
    end
  end # class Group

  module PaintableGroup
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
  end # module Paintable Group
end # module FreeVikings
