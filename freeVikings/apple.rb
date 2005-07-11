# apple.rb
# igneus 21.6.2005

require 'item.rb'

module FreeVikings

=begin
= Apple
Apple is a very simple ((<Item>)). It contains vitamin C, so it can heal the
hurted viking (it adds him one energy point if he isn't totally healthy).
=end

  class Apple < Item

    def init_images
      @image = Image.load 'apple.tga'
    end

    def apply(user)
      if user.respond_to? :heal then
        return user.heal
      end
      return false
    end
  end # class Apple
end # module FreeVikings
