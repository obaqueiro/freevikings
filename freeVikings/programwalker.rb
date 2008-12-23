# programwalker.rb
# igneus 23.12.2008

module FreeVikings

  # Is used for scripting of some monsters: accepts a lisp-list-like
  # data structure, recognizes some "control structures" and
  # on demand provides command.

  class ProgramWalker

    # known_commands:: Array of recognized commands
    # array:: one of special tokens:
    #
    # * control structures (reserved words!)
    # [token1, token2, ...]    # set of tokens
    # [:repeat, n, token]      # repeat token n times; 0 means forever
    # * commands (you can overwrite them):
    # [:command_symbol, arg1, arg2, ...]
    
    def initialize(array, known_commands=[:wait, :go])
      @src = array

      @child_walker = nil

      @running = true

      if @src.empty? then
        raise ArgumentError, "program contains empty Array!"
      end

      if @src.first.is_a? Array then
        @type = :set
        @index = 0
      elsif @src.first == :repeat
        @type = :repeat
        @i = @src[1]
      else
        @type = :command
      end

      # puts "#{@type}: #{@src.inspect}"
    end

    def running?
      case @type
      when :command
        return @running
      when :set
        if (@index < @src.size) then
          return true
        elsif @child_walker && @child_walker.running?
          return true
        else
          return false
        end
      when :repeat
        return @i == -1 || @i > 0 || (@child_walker && @child_walker.running?)
      end
    end

    # Troll asks for next command as soon as he finished the last one;
    # this method is used for it.

    def next_command
      if @child_walker && @child_walker.running? then
        # puts @i if @type == :repeat
        return @child_walker.next_command
      else
        @child_walker = nil
      end

      case @type
      when :command
        @running = false
        return @src
      when :set
        @child_walker = ProgramWalker.new @src[@index]
        @index += 1
        return @child_walker.next_command
      when :repeat
        if @i > 0 then
          @i -= 1
        elsif @i == -1 then
          # repeat forever...
        else
          return nil
        end

        @child_walker = ProgramWalker.new @src[2]
        return @child_walker.next_command
      end
    end

    private

    def control_structure?(array)
      array.first.is_a?(Array) || (array.first == :repeat)
    end

    def command?(array)
      known_commands.include?(array.first)
    end
  end # class ProgramWalker
end
