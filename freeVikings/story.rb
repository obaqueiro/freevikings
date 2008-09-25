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

    # Frame which displays portrait of a speaker and his sentence.

    class TalkFrame < Frame

      TEXT_WIDTH = 300
      LEFT = Story::Frame::WIDTH/2-TEXT_WIDTH/2 + 30
      TOP = 100

      # Accepts a (started! speakers are needed!) Talk. Returns an Array
      # of TalkFrame instances.

      def TalkFrame.talk_to_frames(talk)
        # Well, possibly there is some better way of doing this then
        # defining a singleton method... But I didn't want to include
        # this method into Talk, because Talk doesn't need to know
        # anything about Story.
        def talk.to_storyframes
          unless running?
            raise "Need speakers!"
          end

          frames = []

          @talk.each do |node|
            frames << TalkFrame.new(@speakers[node['speaker']], node['say'])
          end

          return frames
        end

        return talk.to_storyframes
      end

      def initialize(speaker, sentence)
        super()

        portrait = speaker.portrait.image
        @surface.blit portrait, [LEFT-60,TOP]

        font = FreeVikings::FONTS['default']
        h = font.height sentence, TEXT_WIDTH
        if h < portrait.h then
          h = portrait.h
        end
        box = RUDL::Surface.new [TEXT_WIDTH, h]
        box.fill speaker.class::FAVOURITE_COLOUR
        font.render box, TEXT_WIDTH, sentence

        @surface.blit box, [LEFT, TOP]
      end
    end

  end
end
