# vikingstate2.rb
# igneus 5.2.2009

module FreeVikings; end

module FreeVikings::New

  class VikingState

    # Yields self if block is given. (To provide convenient way of 
    # initialization.)

    def initialize
      if block_given? then
        yield self
      end
    end

    # Sets table of states.
    # Can be called just once for each object.
    # Must be called before any other operations.
    # Table of states is a Hash where keys are Symbols and
    # values are Arrays of Symbols.
    # Maps states (represented by Symbols) to sets of states which can
    # follow.
    # Table is frozen!
    # As side effect for every state :somestate defines method
    # somestate!, which equals to 'set(:somestate)'.

    def table=(t)
      if @table then
        raise "Can't assign table of symbols. Table of states has already "\
        "been assigned!"
      end

      @table = t
      @table.freeze

      @state = nil # state symbol

      @table.keys.each do |s|
        # define setting shortcut: somestate!
        eval "def self.#{s}!\n"\
        "       set :#{s}\n"\
        "     end"

        # define shortcut predicate: somestate?
        eval "def self.#{s}?\n"\
        "       @state == :#{s}\n"\
        "     end"
      end
    end

    # Returns current state

    attr_reader :state

    # Sets initial state. Omits check of 'consequentibility'.
    # Can be called just once.

    def set_initial(state)
      if @state
        raise "State has already been set! Can't set new initial state."
      end

      unless valid_state?(state)
        raise InvalidStateException, "'state' is not valid state."
      end

      @state = state
    end

    # Sets a new state. Argument new_state is Symbol (present as key in
    # table of states!)

    def set(new_state)
      unless @state
        raise "No initial state has been given yet. Can't change state."
      end

      unless valid_state?(new_state)
        raise InvalidStateException, "'state' is not valid state."
      end

      unless @table[@state].include?(new_state)
        raise StateCannotFollowException.new(@state,new_state)
      end

      @state = new_state
    end

    # Returns unsorted Array of valid states (Symbols).

    def all_states
      @table.keys
    end

    def valid_state?(s)
      all_states.include? s
    end

    class InvalidStateException < ArgumentError; end

    class StateCannotFollowException < ArgumentError
      def initialize(s1,s2)
        @states = [s1,s2]
        @message = "State '#{s2}' cannot immediatelly follow after '#{s1}'."
      end
      attr_reader :states
      attr_reader :message
    end
  end
end
