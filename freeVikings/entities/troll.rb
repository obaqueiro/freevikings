# troll.rb
# igneus 23.12.2008

require 'programwalker.rb'
require 'monstermixins.rb'

module FreeVikings

  # Troll behaves according to the program; when he is disturbed (e.g. hurt
  # or sees a viking), he forgets the program and attacks; later he might 
  # return to the program

  class Troll < Sprite

    include Monster
    include MonsterMixins::ShieldSensitive

    COMMANDS = [:go, :wait, :die]

    VELOCITY = 30.0

    WIDTH = 80
    HEIGHT = 80

    # program must be valid input for ProgramWalker!
    # known commands:
    # * [:go, y]
    # * [:wait, seconds]
    # * [:die]

    def initialize(pos, program)
      super(pos)
      @energy = 3

      @program = ProgramWalker.new program, COMMANDS

      # Rectangle used for hero detection; it is always placed next to troll
      # and collisions are checked
      @check_rectangle = Rectangle.new(0,0,WIDTH*5,HEIGHT)

      take_new_command

      # :program or :berserk ; :berserk means that troll saw a viking 
      # near to himself and waits to kill him.
      @mode = :program 

      @state = 'normal_right'

      # TimeLock which ensures delay between two blows of troll's deadly rod
      @attack_timer = TimeLock.new(0) if @attack_timer.nil?
    end

    alias_method :collision_rect, :rect

    def paint_rect
      if @state == :normal_left then
        unless defined?(@thinrect)
          @thinrect = R(0, @rect.top, 60, @rect.h) 
        end
        @thinrect.left = @rect.left + 20
        return @thinrect
      else
        return @rect
      end
    end

    attr_reader :state

    # Does common update work for both modes and then calls another method 
    # which does mode-specific work

    def update
      # check for vikings seen by the troll
      @check_rectangle.top = @rect.top
      @check_rectangle.left = if @direction == -1 then
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
        update_attack or update_mode_berserk
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
        if (@direction == -1 && next_x <= @destination_x) ||
            (@direction == 1 && next_x >= @destination_x) then
          next_x = @destination_x
        end

        @rect.left = next_x
      end

      if ! @vikings_seen.empty? then
        @mode = :berserk
      end
    end

    ATTACK_DELAY = 1.5

    # update for mode :berserk

    def update_mode_berserk
      if @vikings_seen.empty? then
        @mode = :program
        return
      end

      if @attack_timer.free? && !@collides_viking.empty? then
        # attack
        attack_start
        @attack_timer = TimeLock.new ATTACK_DELAY, @location.ticker
      else
        # move to some viking (to attack him)
        if ! @collides_viking.empty? then
          # troll collides with some viking, he won't move
          return
        elsif stopped_by_shield? then
          # troll collides with shield, he won't move
          return
        else
          @rect.left += @location.ticker.delta * @direction * VELOCITY
        end
      end
    end

    public

    def image
      @image.image(self)
    end

    def init_images
      spritesheet = SpriteSheet.load('troll.png', 
                                     {'norm' => R(0,0,60,80), 
                                       'attack' => R(120,0,80,80)})
      @image = Model.new({'normal_right' => spritesheet['norm'],
                           'normal_left' => spritesheet['norm'].mirror_x})
      @image.add_pair 'attack_right', spritesheet['attack'], false
      @image.add_pair 'attack_left', spritesheet['attack'].mirror_x, false
      @image.inspect
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
          @state = @direction == 1 ? 'normal_right' : 'normal_left'
        end

      else
        # program ended; wait forever
        puts "Program ended. Kill me! Waiting is so BOOORING!"
        @program = ProgramWalker.new [:repeat, -1, [:wait, 10]], COMMANDS
        take_new_command
      end
    end

    # Methods about attack:

    def update_attack
      return false unless attacking?

      if @attacking.free? then
        attack_end
      end

      return true
    end

    def attack_start
      if @direction == 1 then
        @state = 'attack_right'
      else
        @state = 'attack_left'
      end
      @attacking = TimeLock.new(0.15, @location.ticker)
      @collides_viking.each {|v| v.hurt}
    end

    def attack_end
      @attacking = nil

      if @direction == 1 then
        @state = 'normal_right'
      else
        @state = 'normal_left'
      end
    end

    def attacking?
      defined?(@attacking) && @attacking != nil
    end
  end # class Troll
end
