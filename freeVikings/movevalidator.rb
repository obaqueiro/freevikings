# movevalidator.rb
# igneus 25.1.2005

# MoveValidator je objekt, ktery urcuje, zda je urcitou posici mozno obsadit
# bez kolize

module FreeVikings

  module MoveValidator
    def is_vertical_position_valid?(sprite, new_position)
      true
    end

    def is_horizontal_position_valid?(sprite, new_position)
      true
    end

    def is_position_valid?(sprite, new_position)
      return (is_vertical_position_valid?(sprite, new_position) and is_horizontal_position_valid?(sprite, new_position))
    end
  end

  class NullMoveValidator
    include MoveValidator
  end
end # module FreeVikings
