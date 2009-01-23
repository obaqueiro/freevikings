# zsortedgroup.rb
# igneus 23.1.2009

module FreeVikings

  # Group which is sorted by members' attribute 'z' and at addition
  # check is performed if added object isn't already present in the group.
  #
  # Track is kept how many time an object has been added and it isn't 
  # really deleted before 'delete' is called so many times that number
  # of additions is reached.

  class ZSortedGroup < SchwerEngine::Group

    def initialize
      super
      @members_presence = {}
    end

    def add(o)
      if @members_presence[o] then
        @members_presence[o] += 1
        return
      end

      i = nil
      @members.each_with_index {|m,j|
        if m.z >= o.z then
          i = j
          break
        end
      }

      unless i
        @members.push o
      else
        @members.insert i, o
      end

      @members_presence[o] = 1
    end

    def delete(o)
      unless @members_presence[o] then
        raise "Object '#{o.inspect}' not here."
      end

      @members_presence[o] -= 1

      if @members_presence[o] > 0 then
        return
      end

      @members_presence.delete o
      @members.delete o
    end
  end
end
