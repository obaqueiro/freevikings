# scrollingcredits.rb
# igneus 1.2.2009

module GameUI
  module Menus

    VIEW_HEIGHT = 200
    SCROLLING_SPEED = 20.0 # pixels per second

    # Credits enhanced by scrolling

    class ScrollingCredits < Menu

      def initialize(parent, people, label='Credits')
        super(parent, label, nil, nil)

        # @title_image is shown in the parent menu
        @title_image = @image

        @image = RUDL::Surface.new([parent.width, 
                                    VIEW_HEIGHT+@title_image.h+Credits::SPACE])

        text_surfaces = []
        credits_height = 0
        people.each do |c|
          name, credit = c

          name_img = create_image(name)
          credit_img = create_image(credit)

          im = RUDL::Surface.new([@width, name_img.h+credit_img.h])
          im.blit(name_img, [0,0])
          im.blit(credit_img, [Credits::INDENT,name_img.h])
          text_surfaces << im
          credits_height += im.h
        end

        @image.blit(@title_image, [0,0])

        @credits_image = RUDL::Surface.new [@width, credits_height]
        y = 0
        text_surfaces.each do |s|
          @credits_image.blit s, [0,y]
          y += s.h + Credits::SPACE
        end

        @scroller = ScrollingImage.new(@credits_image, VIEW_HEIGHT, 
                                       SCROLLING_SPEED)

        QuitButton.new(self)

        # coordinates where @credits_image should always be blitted on @image
        @credits_coord = [0,@title_image.h+Credits::SPACE]
      end

      def paint(surface, coordinates)
        surface.blit @title_image, coordinates
      end

      def height
        @title_image.h
      end

      def prepare
        @scroller.reset
        @image.fill [0,0,0], [@credits_coord[0], @credits_coord[1], 
                              @image.w, @image.h]
      end

      def update_surface
        @scroller.paint(@image, @credits_coord)
        super
      end
    end

    class ScrollingImage

      # scroll_speed: pixels per second

      def initialize(image, view_height, scroll_speed)
        @image = image
        @view_height = view_height
        @scroll_speed = scroll_speed

        reset
      end

      def reset
        @last_update = Time.now.to_f

        # @by:
        #
        # where bottom edge of @credits_view is 
        # (relative to top of "painted window"):
        #
        # O-----O top of "painted window"    
        # |     |
        # |     | X---X @image
        # |     | |   |
        # O-----O |   |
        #         |   |
        #         |   |
        #         X---X <------------- @by
        @by = @view_height + @image.h
      end

      # updates and paints scrolled image on given coordinates

      def paint(surface, coordinates)
        if @by > @view_height then
          surface.fill [0,0,0], [coordinates[0], coordinates[1], 
                                 @image.w, @image.h]
        end

        dy = coordinates[1] + ty
        sy = ty >= 0 ? 0 : -ty
        sh = @view_height - ty
        
        surface.blit @image, [0,dy], [0,sy,@image.w,sh]

        move!
      end

      private

      # called once per paint, 'scrolls' @by and updates time

      def move!
        time_now = Time.now.to_f
        @by -= (time_now - @last_update) * @scroll_speed
        @last_update = time_now

        if @by <= 0 then
          @by = @view_height + @image.h
        end
      end

      # returns y coordinate of @image in 'painted window'

      def ty
        @by - @image.h
      end
    end
  end
end
