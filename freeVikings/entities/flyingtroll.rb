# flyingtroll.rb
# 26.12.2008

require 'programwalker.rb'
require 'entities/arrow.rb'
require 'monster'
require 'monstermixins'

module FreeVikings

  # FlyingTroll looks like an 'angel' (I mean those angels on baroque
  # altars or in tales-books - not 'tous angellous tou Kyriou') or Amor 
  # - except of his skin, which is green...
  # Compared with regular Troll he is relatively peaceful - he doesn't
  # look for vikings to attack, just flies and from time to time shoots 
  # an arrow from his bow.

  class FlyingTroll < Sprite

    include Monster
    include MonsterMixins::ShieldSensitive

    WIDTH = 50 # width of collision_rect; paint_rect is 100px wide
    HEIGHT = 100

    VELOCITY = 70

    ARROW_Y = 48 # arrow_y = @rect.top + ARROW_Y
    ARROW_VELOCITY = 100

    # Commands:
    # [:wait, seconds]
    # [:go, [x,y]]
    # [:die]
    # [:shoot] - shoots immediately, regardless the delay
    # [:shoot_period, seconds] - change time between regular shooting;
    # nil means 'shoot on demand only'

    def initialize(position, program)
      super(position)
      @paint_rect = R(0,0,100,100)

      @program = ProgramWalker.new program, [:wait, :go, :die, :shoot, :shoot_period]
      take_new_command

      @energy = 3

      @direction = 1
      @vertical_direction = 0

      @shoot_period = 5 # wait seconds between two arrows

      @wait_lock = TimeLock.new(0) # timer for waiting (on command :wait)
      @shoot_lock = TimeLock.new(@shoot_period) # timer for shooting
    end

    def paint_rect
      @paint_rect.top = @rect.top
      @paint_rect.left = if @direction == -1 then
                           @rect.left
                         else
                           @rect.left - (@paint_rect.w - @rect.w)
                         end
      return @paint_rect
    end

    # == update and state related methods

    def update
      if command_done? then
        take_new_command
        return
      end

      # shooting
      if @shoot_lock.free? && @shoot_period != nil then
        shoot
        @shoot_lock = TimeLock.new(@shoot_period)
      end

      # check shield; troll can't fly through it
      if stopped_by_shield? then
        return
      end

      # movement
      if @command[0] == :go then
        td = @location.ticker.delta
        next_pos = [@rect.left + td * @direction * VELOCITY,
                    @rect.top + td * @vertical_direction * VELOCITY]

        if (@destination[1] <=> next_pos[1]) != @vertical_direction then
          next_pos[1] = @destination[1]
        end
        if (@destination[0] <=> next_pos[0]) != @direction then
          next_pos[0] = @destination[0]
        end

        @rect.left, @rect.top = next_pos
      end
    end

    private

    def command_done?
      case @command[0]
      when :go
        return @rect.top_left == @destination
      when :wait
        return @wait_lock.free?
      when :shoot, :shoot_period
        return true
      end
    end

    def take_new_command
      if @program.running?
        @command = @program.next_command

        case @command.first
        when :die
          destroy
        when :wait
          @wait_lock = TimeLock.new @command[1]
        when :go
          # puts @command.inspect
          @destination = @command[1]
          @direction = @destination[0] <=> @rect.left
          @vertical_direction = @destination[1] <=> @rect.top
        when :shoot_period
          @shoot_period = @command[1]
        when :shoot
          shoot
        end

      else
        # program ended; wait forever
        puts "Program ended. Kill me! Waiting is so BOOORING!"
        @program = ProgramWalker.new [:repeat, -1, [:wait, 10]], COMMANDS
        take_new_command
      end
    end

    def shoot
      x = (@direction == -1) ? @rect.left : (@rect.right - Arrow::WIDTH)
      y = @rect.top + ARROW_Y
      a = Arrow.new([x,y], ARROW_VELOCITY*@direction)
      a.hunted_type = Hero
      @location << a
    end

    public

    # == graphics related methods

    def state
      @direction == -1 ? 'left' : 'right'
    end

    def image
      @model.image(self)
    end

    def init_images
      ss = SpriteSheet.load('flyingtroll.png', 
                            {1 => R(0,0,100,100),
                              2 => R(100,0,100,100)})
      r = Animation.new(0.2, [ss[1], ss[2]])
      l = Animation.new(0.2, [ss[1].mirror_x, ss[2].mirror_x])
      @model = Model.new({'right' => r, 'left' => l})
    end
  end
end
