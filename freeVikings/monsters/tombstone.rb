# tombstone.rb
# igneus 15.6.2005

# When a monster is killed, instead of it's corpse a nice tombstone
# appears (and it disappears soon, too).
# FreeVikings aren't a bloody game...

# RIP == REQUIESCAT IN PACE == I wish he would rest in peace

require 'sprite.rb'

module FreeVikings

  class Tombstone < Sprite

    TIME_OF_EXISTENCY = 3

    HEIGHT = 50
    WIDTH = 50

    def initialize(initial_position)
      pos = initial_position
      if pos.size >= 4 then
        pos.top += pos.h - HEIGHT
      end
      pos.w = WIDTH
      pos.h = HEIGHT
      super pos
      @appear_time = Time.now.to_i
      @state = StateStone.new
    end

    def hurt
      nil
    end

    def update
      if Time.now.to_i >= @appear_time + @state.duration then
        @appear_time += @state.duration
        if @state.next.nil? then
          destroy
          return
        else
          @state = @state.next.new
        end
      end
    end

    def image
      @state.image.image
    end

    attr_reader :state

    private

    class State
      attr_reader :to_s
      attr_reader :image
      attr_reader :duration
      attr_reader :next
    end # class TombStoneState

    class StateStone < State
      def initialize
        @to_s = 'stone'
        @image = Image.new 'tombstone.tga'
        @duration = 2.5
        @next = StateBigCloud
      end
    end # class StateStone

    class StateBigCloud < State
      def initialize
        @to_s = 'puff1'
        @image = Image.new 'puff_cloud1.tga'
        @duration = 0.5
        @next = StateSmallCloud
      end
    end # class StateBigCloud

    class StateSmallCloud < State
      def initialize
        @to_s = 'puff2'
        @image = Image.new 'puff_cloud2.tga'
        @duration = 0.5
        @next = nil
      end
    end # class StateSmallCloud
  end # class Tombstone
end # module FreeVikings
