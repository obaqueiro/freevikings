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

      # Rectangle used for hero detection; it is always placed next to troll
      # and collisions are checked
      @check_rectangle = Rectangle.new(0,0,WIDTH*5,HEIGHT)

      take_new_command

      # :program or :berserk ; :berserk means that troll saw a viking 
      # near to himself and waits to kill him.
      @mode = :program 
    end

    alias_method :collision_rect, :rect

    # Does common update work for both modes and then calls another method 
    # which does mode-specific work

    def update
      # check for vikings seen by the troll
      @check_rectangle.top = @rect.top
      @check_rectangle.left = if @direction = -1 then
                                @rect.left - @check_rectangle.w
                              else
                                @rect.right
                              end
      @vikings_seen = [] # vikings colliding with @check_rectangle
      @collides_viking = [] # vikings colliding with @rect
      @location.heroes_on_rect(@check_rectangle) {|h|
        @vikings_seen << h
        if @rect.collides? h.rect then
          @collides_viking << h
        end
      }

      case @mode
      when :program
        update_mode_program
      when :berserk
        update_mode_berserk
      else
        raise "Unknown mode '#{@mode}'"
      end
    end

    private

    # update for mode :program

    def update_mode_program
      if command_done? then
        take_new_command
        return
      end

      # move
      if @command.first == :go then
        # puts @location.ticker.delta, @direction, VELOCITY
        next_x = @rect.left + (@location.ticker.delta * @direction * VELOCITY)
        if (@destination_x <=> next_x) != @direction then
          next_x = @destination_x
        end

        @rect.left = next_x
      end

      if ! @vikings_seen.empty? then
        @mode = :berserk
        puts @mode

      end
    end

    # update for mode :berserk

    def update_mode_berserk
      if @vikings_seen.empty? then
        @mode = :program
        puts @mode
        return
      end

      @attack_timer = TimeLock.new(-500,@location.ticker) if @attack_timer.nil?

      if @attack_timer.free? then
        # attack
        @collides_viking.each {|v| v.hurt}
        @attack_timer = TimeLock.new 3, @location.ticker
      else
        # move to some viking (to attack him)
        unless @collides_viking.empty? then
          # troll collides with some viking, he won't move
          return
        end

        @rect.left += @location.ticker.delta * @direction * VELOCITY
      end
    end

    public

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
