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
  end # class Group
end # module FreeVikings
