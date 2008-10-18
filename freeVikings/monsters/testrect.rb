# testrect.rb
# igneus 18.10.2008

module FreeVikings

  # Pseudo-monster used for testing if some rectangle is free
  # and getting it's coordinates (develmagic feature)

  class TestRect < Sprite

    def initialize(rect, dismiss_after=6)
      super(rect)
      @dismiss_after = dismiss_after      
    end

    def location=(location)
      super

      if location.kind_of? Location then
        init_img
        @dismiss_lock = TimeLock.new(@dismiss_after)

        puts "#{@rect.to_s}: #{@free ? 'free' : 'non-free'}"
      end
    end

    def update
      if @dismiss_lock.free? then
        @location.delete_sprite self 
      end
    end

    private

    def init_img
      s = RUDL::Surface.new [@rect.w, @rect.h]
      @free = @location.area_free?(@rect)
      colour = @free ? [0,255,0] : [255,0,0]
      s.fill colour
      s.print [1,1], @rect.to_s, [255,255,255]
      @image = SchwerEngine::Image.wrap s
    end
  end
end
