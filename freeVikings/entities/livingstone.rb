# livingstone.rb
# igneus 19.12.2008

module FreeVikings

  # Prety monster which lives in the underground caves (because it hates
  # light as it's relatives - trolls). Normally it looks just like a regular 
  # stone, but from time to time it wakes up and rolls somewhere else
  # or even attacks other creatures (mainly people). It is said that
  # LivingStones can spit out their teeth (which are, of course, made of heavy 
  # stone).

  class LivingStone < Sprite

    include Monster

    WIDTH = HEIGHT = 80

    def initialize(position, min_x, max_x)
      @move_per_frame = 30
      @frame_time = 0.4

      @last_move = 0

      super(position)
      @waypoints = [min_x, max_x-WIDTH]

      next_waypoint # to set @image
    end

    def update
      wx = @waypoints.first
      if @location.ticker.now >= @last_move + @frame_time
        direction = wx < @rect.left ? -1 : 1
        @rect.left += direction * @move_per_frame
        if (direction < 0 && @rect.left < wx) || (direction > 0 && @rect.left > wx) then
          next_waypoint
        end
        @last_move = @location.ticker.now
      end
    end

    def init_images
      framenames = []
      6.times {|i| framenames << 'roll '+i.to_s}
      framenames += ['wake up', 'look', 'spit']
      spritesheet = SpriteSheet.load2('livingstone.png', 80, 80, framenames)

      frames = []
      6.times {|i| frames << spritesheet['roll '+i.to_s]}
      @image_right = Animation.new(@frame_time, frames)
      @image_left = Animation.new(@frame_time, frames.reverse)
    end

    private

    def next_waypoint
      @waypoints.push @waypoints.shift

      if @waypoints.first < @rect.left then
        @image = @image_left
      else
        @image = @image_right
      end
    end
  end
end
