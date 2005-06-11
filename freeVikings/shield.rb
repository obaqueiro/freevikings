# shield.rb
# igneus 11.6.2005

=begin
= Shield
Shield is an object with special features. It stops all the shots and
can be used as a solid platform for vikings who can jump onto it (I know only
one such viking - his name is Erik).
=end

module FreeVikings

  class Shield < Sprite

    WIDTH = 15
    HEIGHT = 80

    def initialize(shielder)
      @shielder = shielder
      @rect = Rectangle.new 0,0,WIDTH,HEIGHT
      init_images
    end

    def update
      unless @shielder.alive?
        destroy
        return
      end
      @rect.left = case state
                     when 'top'
                       @shielder.rect.left 
                     when 'left'
                       @shielder.rect.left - 20 - 2
                     when 'right'
                       @shielder.rect.right + 2
                     end # case state
      @rect.top = case state
                     when 'top'
                       @shielder.rect.top - 10 - 1
                     when 'left', 'right'
                       @shielder.rect.top + 10
                     end # case state
      @rect.h = image.h
      @rect.w = image.w

      @location.sprites_on_rect(self.rect).each do |s|
        if s.kind_of? Shot and @shielder.kind_of? s.hunted_type
          s.destroy
        end
      end
    end # method update

    def state
      @shielder.shield_use
    end
    
    private

    def init_images
      # Zde je velmi dulezite zachovat poradi nahravani obrazku, aby se
      # nahraly opravdu vsechny.
      # Na pocatku je totiz @rect nastaven na sirku 15 a vysku 80,
      # tedy na rozmery, jake ma stit ve vertikalni poloze.
      # Posledni obrazek ale patri stitu v poloze horizontalni a jeho
      # rozmery jsou tedy prevracene. Po jeho nahrani bude vyhozena vyjimka,
      # kterou ale zachytime a vsechno pujde v pohode dal.
      begin
        @image = ImageBank.new self
        @image.add_pair 'left', Image.new('shield_left.png')
        @image.add_pair 'right', Image.new('shield_right.png')
        @image.add_pair 'top', Image.new('shield_top.png')        
      rescue RuntimeError
      end
    end
  end # class Shield
end # module FreeVikings
