# shield.rb
# igneus 11.6.2005

=begin
= Shield
Shield is an object with special features. It stops all the shots and
can be used as a solid platform for vikings who can jump onto it (I know only
one such viking - his name is Erik).
=end

module FreeVikings

  class Shield < SchwerEngine::Entity

    include StaticObject

    WIDTH = 15
    HEIGHT = 80

=begin
--- Shield.new(shielder)
This is an irregular method. It creates a Sprite, but it's only argument
isn't an Array or a Rectangle, but another Sprite - the shielder.
It's a man (or woman, monster, ...) who carries the shield.
=end

    def initialize(shielder)
      super([0,0])
      @shielder = shielder

      @z = @shielder.z
      @rect = Rectangle.new 0,0,WIDTH,HEIGHT

      init_images
    end

    def semisolid?
      if state == 'top'
        return true
      else
        return false
      end
    end

    # Not Thor himself is able to destroy Olaf's shield.

    def destroy
      false
    end

    # Method unofficial_update is a hack to ensure the Shield is updated
    # just after the Shielder. Simply: after the Shielder is updated, it calls
    # unofficial_update over his shield.
    # It's important to update them subsequently,
    # because they have to move together.

    def unofficial_update(location)
      @rect.left = case state
                     when 'top'
                       @shielder.paint_rect.left
                     when 'left'
                       @shielder.paint_rect.left - WIDTH - 2
                     when 'right'
                       @shielder.paint_rect.right + 2
                     end # case state
      @rect.top = case state
                     when 'top'
                       @shielder.rect.top - 10 - 1
                     when 'left', 'right'
                       @shielder.rect.top + 10
                     end # case state
      @rect.h = image.h
      @rect.w = image.w

      location.sprites_on_rect(self.rect).each do |s|
        if s.kind_of? Shot and @shielder.kind_of? s.hunted_type
          s.destroy
        end
      end
    end

    def state
      @shielder.shield_use
    end
    
    def init_images
      # Zde je velmi dulezite zachovat poradi nahravani obrazku, aby se
      # nahraly opravdu vsechny.
      # Na pocatku je totiz @rect nastaven na sirku 15 a vysku 80,
      # tedy na rozmery, jake ma stit ve vertikalni poloze.
      # Posledni obrazek ale patri stitu v poloze horizontalni a jeho
      # rozmery jsou tedy prevracene. Po jeho nahrani bude vyhozena vyjimka,
      # kterou ale zachytime a vsechno pujde v pohode dal.
      begin
        @image = Model.new
        @image.add_pair 'left', Image.load('shield_left.png')
        @image.add_pair 'right', Image.load('shield_right.png')
        @image.add_pair 'top', Image.load('shield_top.png')        
      rescue RuntimeError
      end
    end
  end # class Shield
end # module FreeVikings
