# healingpotion.rb
# igneus 7.2.2009

module FreeVikings

  # Magical potion which 'super-heals' viking (gives him any number of energy
  # points missing to HealingPotion::MAX)

  class HealingPotion < Item

    # How many energy points should a super-healed viking have?
    MAX = 4

    def init_images
      @image = Image.load 'healingpotion.png'
    end

    def apply(user)
      add = MAX - user.energy

      if add <= 0 then
        # viking doesn't need healing
        return false
      end

      begin
        user.heal add
      rescue RuntimeError
        # Viking#heal raises error to notify us that standard Viking's
        # energy is exceeded. But magical effect of this potion needs
        # to add more than standard ...
      end
      return true
    end
  end
end
