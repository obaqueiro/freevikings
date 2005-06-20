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
        eir = 0
        sr = member.rect
        eir += 1 if sr.left > locr.left and sr.left < locr.right
        eir += 1 if sr.right > locr.left and sr.right < locr.right
        eir += 1 if sr.top > locr.top and sr.top < locr.bottom
        eir += 1 if sr.bottom > locr.top and sr.bottom < locr.bottom
        if eir >= 2 then
          relative_left = member.left - rect_of_location[0]
          relative_top = member.top - rect_of_location[1]
          surface.blit(member.image, [relative_left, relative_top])
        end
      }
    end
  end # module Paintable Group
end # module FreeVikings
