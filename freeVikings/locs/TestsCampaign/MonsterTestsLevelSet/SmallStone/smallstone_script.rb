# smallstone_script.rb
# igneus 22.12.2008

require 'smallstone'

class StoneMaker < Sprite

  def initialize(pos)
    super(pos)

    @image = Image.wrap(RUDL::Surface.new([10,10]))
  end

  def update
    if @lock.nil? || @lock.free? then
      @location << SmallStone.new(@rect.center, 100, (Math::PI/3)*1.2)

      @lock = TimeLock.new 4
    end
  end
end

LOCATION << StoneMaker.new([300,300,5,5])
