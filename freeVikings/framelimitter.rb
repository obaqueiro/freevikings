# framelimitter.rb
# igneus 5.2.2009

module FreeVikings

  # Implements automatic frame limit.
  # As a sort of "effect per accidens" computes fps.

  class FrameLimitter

    # how often fps should be tested (and delay modified if needed)
    TEST_FRAMES = 30

    # frame_limit is maximum number of frames per second;

    def initialize(frame_limit)
      @frame_limit = frame_limit

      reset
    end

    private

    # resets internals to compute fps from new start

    def reset
      @start_time = get_time

      @total_pause_time = 0
      @start_pause = nil

      @frames = 0
      @fps = 0

      @frames_since_delay_update = 0

      @delay = 0
    end

    public

    # count frame;
    # does nothing when object is paused

    def frame_tick
      return if paused?

      @frames += 1
      @frames_since_delay_update += 1
      @fps = (@frames.to_f / total_time).to_i

      if @frames_since_delay_update >= TEST_FRAMES then
        update_delay
      end
    end

    # perform automatic delay (if needed)

    def perform_delay
      sleep @delay
    end

    # returns current frame rate;

    attr_reader :fps

    # pause concerns only computage of fps - not performing delay

    def pause
      if paused? then
        raise "Object is already paused, can't be paused again!"
      end
      @start_pause = get_time
    end

    def unpause
      unless paused?
        raise "Object isn't paused, can't be unpaused!"
      end
      @total_pause_time += get_time - @start_pause
      @start_pause = nil
    end

    # says if object is paused now

    def paused?
      @start_pause != nil
    end

    private

    # current time

    def get_time
      Time.now.to_f
    end

    # time since start (without pauses)

    def total_time
      (get_time - @start_time) - @total_pause_time
    end

    def update_delay
      return unless @fps > @frame_limit
      
      time_per_frame = total_time / @frames
      wanted_time_per_frame = 1.0 / @frame_limit
      delay = wanted_time_per_frame - time_per_frame

      puts "Delay changed from #{@delay} to #{delay}."
      puts "tpf: #{time_per_frame}"
      puts "wanted tpf: #{wanted_time_per_frame}"

      reset

      @delay = delay

      p @delay
    end
  end

  # Frame limitter with constant delay;
  # delay computation is thus disabled.

  class ConstantDelayFrameLimitter < FrameLimitter

    # delay should be real number (seconds; usually 0 <= delay < 1)

    def initialize(delay)
      super(0)
      @delay = delay
    end

    def perform_delay
      sleep @delay
    end

    private

    # rewritten parent's useless method; leave it empty

    def update_delay
    end
  end

  # Frame limitter with no delay;
  # just computes fps. It's a bit something like a mock-class :)

  class UnlimitedFrameLimitter < FrameLimitter
    def initialize()
      super(0)
    end

    def perform_delay
    end

    private

    def update_delay
    end
  end
end
