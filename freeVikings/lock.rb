# lock.rb
# igneus 30.7.2005

=begin
= Lock
((<Lock>)) is a Static object which waits until someone unlocks it.
Then some action is usually performed.
To unlock the ((<Lock>)) one needs a (({Key})). There are several
colour variants of the (({Key}))s and ((<Lock>))s and to unlock
a ((<Lock>)) you need a (({Key})) of the same colour.
=end

module FreeVikings

  class Lock

    def initialize
      @locked = true
    end

    def locked?
      @locked
    end

    def unlock(key)
    end
  end # class Lock
end # module FreeVikings
