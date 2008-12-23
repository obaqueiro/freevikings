# troll.rb
# igneus 23.12.2008

require 'programwalker.rb'

module FreeVikings

  # Troll behaves according to the program; when he is disturbed (e.g. hurt
  # or sees a viking), he forgets the program and attacks; later he might 
  # return to the program

  class Troll < Sprite

    include Monster

    COMMANDS = [:go, :wait, :die]

    VELOCITY = 30.0

    WIDTH = 60
    HEIGHT = 80

    # program must be valid input for ProgramWalker!
    # known commands:
    # * [:go, y]
    # * [:wait, seconds]
    # * [:die]

    def initialize(pos, program)
      super(pos)
      @program = ProgramWalker.new program, COMMANDS
      take_new_command
    end

    alias_method :collision_rect, :rect

    def update
      if command_done? then
        take_new_command
        return
      end

      if @command.first == :go then
        # puts @location.ticker.delta, @direction, VELOCITY
        next_x = @rect.left + (@location.ticker.delta * @direction * VELOCITY)
        if (@destination_x <=> next_x) != @direction then
          next_x = @destination_x
        end

        @rect.left = next_x
      end
    end

    def init_images
      spritesheet = SpriteSheet.load 'troll.png', {'i' => Rectangle.new(0,0,60,80)}
      @image = spritesheet['i'] 
    end

    private

    def command_done?
      case @command[0]
      when :go
        return @rect[0] == @destination_x
      when :wait
        return @wait_lock.free?
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
          @destination_x = @command[1]
          @direction = (@destination_x <=> @rect.left)
        end

      else
        # program ended; wait forever
        puts "Program ended. Kill me! Waiting is so BOOORING!"
        @program = ProgramWalker.new [:repeat, -1, [:wait, 10]], COMMANDS
        take_new_command
      end
    end
  end # class Troll
end
