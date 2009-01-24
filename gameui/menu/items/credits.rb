# credits.rb
# igneus 16.8.2008

module GameUI
  module Menus

    # This MenuItem, when pushed, shows a window with a list of
    # people and their credits.
    class Credits < Menu

      # Indentation of credits      
      INDENT = 30

      # vertical space left between two persons
      SPACE = 10

      # 'people' is an Array of pairs who-what.
      # example: [['matz', 'main developer of Ruby'], 
      #           ['igneus', 'freeVikings programmer']]
      def initialize(parent, people, label='Credits')
        super(parent, label, nil, nil)

        # @title_image is shown in the parent menu
        @title_image = @image

        # @image contains title and list of people and their credits
        @image = RUDL::Surface.new([parent.width, 250])
        @image.blit(@title_image, [0,0])

        y = @title_image.h + Menu::TITLE_MARGIN_BOTTOM
        people.each do |p|
          name, credit = p
          
          name_img = create_image(name)
          @image.blit(name_img, [0,y])
          credit_img = create_image(credit)
          @image.blit(credit_img, [INDENT,y+name_img.h])

          y = y + name_img.h + credit_img.h + SPACE
        end        

        QuitButton.new(self)
      end

      def paint(surface, coordinates)
        surface.blit @title_image, coordinates
      end

      def height
        @title_image.h
      end
    end
  end
end
