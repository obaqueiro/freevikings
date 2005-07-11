# dark_monsters.rb
# igneus 14.3.2005
# Skript priser pro lokaci dark_loc.xml

require 'imagebank'

class Apex < FreeVikings::Sprite

  def initialize(position)
    super(position)
    @image = FreeVikings::Image.load 'apex.tga'
  end

  def update
    colliding_sprites = @location.sprites_on_rect(rect)
    colliding_sprites.each {|s| s.hurt if s.kind_of? Hero}
  end
end

TS = 40 # tile side length

MONSTERS = []

# Bodaky v dire v horni chodbe:
4.times {|i| MONSTERS.push Apex.new([33*TS + i*TS, 7*TS])}

# Bodaky na schode dolu:
MONSTERS.push Apex.new [5*TS, 14*TS]
MONSTERS.push Apex.new [6*TS, 15*TS]

# Bodaky v dire dole:
11.times {|i| MONSTERS.push Apex.new([7*TS + i*TS, 23*TS])}
