# movevalidator.rb
# igneus 25.1.2005

# MoveValidator je objekt, ktery urcuje, zda je urcitou posici mozno obsadit
# bez kolize

module FreeVikings

  module MoveValidator
    def is_position_valid?(sprite, position)
      nil
    end
  end

  class NullMoveValidator
    include MoveValidator
  end
end # module FreeVikings
