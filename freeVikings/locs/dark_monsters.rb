# dark_monsters.rb
# igneus 14.3.2005
# Skript priser pro lokaci dark_loc.xml

require 'imagebank'

class Apex < FreeVikings::Sprite

  def initialize(position)
    super(position)
    @image = FreeVikings::Image.new 'apex.tga'
  end
end

MONSTERS = []

# Bodaky v dire v horni chodbe:
4.times {|i| MONSTERS.push Apex.new([1320 + i*40, 290])}

# Bodaky na schode dolu:
MONSTERS.push Apex.new [200, 480]
MONSTERS.push Apex.new [240, 520]

# Bodaky v dire dole:
11.times {|i| MONSTERS.push Apex.new([280 + 40*i, 840])}
