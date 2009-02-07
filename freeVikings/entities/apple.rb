# apple.rb
# igneus 21.6.2005

module FreeVikings

  # Apple is a very simple Item. It contains vitamin C, so it can heal the
  # hurted viking (it adds him one energy point if he isn't totally healthy).

  class Apple < Item

    def init_images
      @image = Image.load 'apple.png'
    end

    def apply(user)
      if user.energy < Viking::MAX_ENERGY then
        user.heal 1
      end
    end
  end # class Apple
end # module FreeVikings
