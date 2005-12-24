# key.rb
# igneus 31.7.2005

=begin
= NAME
Key

= DESCRIPTION
((<Key>)) is an (({Item})) used to unlock the (({Lock})).

= Superclass
Item
=end

require 'lock.rb'

module FreeVikings

  class Key < Item

    include Lock::Colour

    # Hash where Lock::Colour constants are keys and corresponding Image 
    # objects values.

    @@images = {RED => Image.load('key_red.tga'),
                GREEN => Image.load('key_green.tga'),
                BLUE => Image.load('key_blue.tga')}

    def initialize(position, colour=RED)
      super(position)
      @colour = colour
      @image = @@images[@colour]
    end

    attr_reader :colour

    def apply(user)
      locks = user.location.static_objects.
              members_on_rect(user.rect).find_all {|o| o.kind_of? Lock}
      
      locks.each do |lock|
        return true if lock.unlock(self)
      end

      return false
    end
  end # class Key
end # module FreeVikings
