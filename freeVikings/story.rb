# story.rb
# igneus 20.9.2008

module FreeVikings

  # Story object is a tool for story telling.

  class Story

    # A normal way to create a new story:
    # s = Story.new do |story|
    #   story << Frame.new(...)
    #   ...
    # end
    def initialize
      @frames = []
      yield self
      start
    end

    # Adds a new frame.

    def <<(frame)
      @frames << frame
    end

    # Jumps to first frame
    # It is called automatically at the end of Story#new, so you should
    # call it only if you reuse the Story

    def start
      @current_frame = 0
    end

    # Jumps to another frame. Returns false if there is no more
    # frame, true otherwise.

    def next
      unless started?
        raise RuntimeError, "Story hasn't been started yet."
      end

      @current_frame += 1
      if @current_frame >= @frames.size then
        return false
      else
        return true
      end
    end

    # Returns true if there is no more frame to display

    def story_completed?
      unless started?
        raise RuntimeError, "Story hasn't been started yet."
      end

      @current_frame >= @frames.size
    end

    # Paints current frame to the given surface

    def paint(surface)
      unless started?
        raise RuntimeError, "Story hasn't been started yet."
      end

      if story_completed? then
        raise RuntimeError, "Story has already ended!"
      end

      @frames[@current_frame].paint(surface)
    end

    def started?
      defined? @current_frame
    end

    # Simple frame.

    class Frame
      WIDTH = FreeVikings::WIN_WIDTH
      HEIGHT = FreeVikings::WIN_HEIGHT

      def initialize
        @surface = RUDL::Surface.new [WIDTH, HEIGHT]
      end

      # You can paint anything on the frame surface.

      attr_reader :surface

      def paint(surface)
        surface.blit @surface, [0,0]
      end
    end

    # Frame of a text

    class TextFrame < Frame

      MARGIN_SIDE = 100
      MARGIN_TOP = 50

      # Arguments:
      # text:: String (text to be displayed)
      # fgcolour:: colour Array (default is [255,255,255] - white)
      # bgcolour:: colour Array (default is [0,0,0] - black)
      def initialize(text, fgcolour=[255,255,255], bgcolour=[0,0,0])
        super()

        @surface.fill bgcolour
        textbox = FreeVikings::FONTS['default'].create_text_box(Frame::WIDTH-2*MARGIN_SIDE, text, fgcolour)
        @surface.blit textbox, [MARGIN_SIDE, MARGIN_TOP]
      end
    end
  end
end
