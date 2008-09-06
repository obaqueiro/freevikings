# menu.rb
# igneus 3.9.2005

require 'RUDL'
require 'menuitem.rb'

module GameUI
  module Menus

    # Menu is a container of special objects - instances of class
    # MenuItem.
    # Menu is a subclass of MenuItem itself so you can build nested 
    # structures and deep trees of Menus.
    #
    # Call Menu#run and let the Menu interact with the user on it's
    # own. 
    #
    # By creating subclasses of MenuItem you can make new buttons, switches
    # etc. which would behave according to your wishes.
    # Use them to let the user configure the game, start or quit it.

    class Menu < MenuItem

      include RUDL
      include RUDL::Constant

      TITLE_MARGIN_BOTTOM = 20

      BACKGROUND_COLOUR = [0, 0, 0]
      SELECTOR_COLOUR = [236, 236, 0]

      DEFAULT_X = 100
      DEFAULT_Y = 50
      DEFAULT_WIDTH = 300

      # movement directions
      UP, DOWN, NO = -1, 1, 0

      # movement delay in seconds
      DELAY = 0.3

      # Creates a new Menu as a child of parent. If you want the newly 
      # created Menu to be a top-level Menu, give nil as a first
      # argument.
      # title must be a String. Argument surface is 
      # a RUDL::Surface onto which the Menu will paint it's contents.
      # Parameter text_renderer must be a GameUI::TextRenderer instance.

      def initialize(parent, title, surface, text_renderer, x=DEFAULT_X, y=DEFAULT_Y, width=DEFAULT_WIDTH)
        super(parent)

        @menu_items = []

        if parent
          @x = parent.x
          @y = parent.y
          @width = parent.width
          @surface = parent.surface
          @text_renderer = parent.text_renderer
        else
          @x = x
          @y = y
          @width = width
          @surface = surface
          @text_renderer = text_renderer
        end

        @update_rect = [@x, 0, @x+@width, @surface.h]

        @image = create_image(title)
        @selector = create_selector()

        @running = false

        # variables for continuous movement of the selector while
        # the user presses a key
        @move = NO
        @last_move_time = 0
      end

      attr_reader :text_renderer

      attr_reader :width

      attr_reader :x

      attr_reader :y

      attr_reader :surface

      def enter
        self.run
      end

      # Gives the control to the Menu which then starts painting itself
      # and reading the events from RUDL::EventQueue.

      def run
        @selected = 0
        @running = true

        prepare

        menu_loop
      end

      # Unless it's a top-level Menu our Menu gives control to it's
      # parent. Otherwise it stops running.

      def quit
        @running = false
        @parent.run if @parent
      end

      # Adds a new item into the Menu.
      # You don't usually need to call this method, it is called from inside 
      # of the added item's constructor.

      def add(menu_item)
        @menu_items.push menu_item
      end

      # Moves the selector (the selection bar) onto the next item of the Menu.

      def select_next
        @selected += 1
        @selected = 0 if @selected >= @menu_items.size
      end

      # Moves the selector back.

      def select_previous
        @selected -= 1
        @selected = @menu_items.size - 1 if @selected < 0
      end

      # Selects index-th item

      def select(index)
        if index >= @menu_items.size then
          raise ArgumentError, "Index '#{index}' out of range - menu has just #{@menu_items.size} items"
        end

        @selected = index
      end

      # Says if the Menu has the control now.

      def running?
        @running
      end

      def prepare
        @menu_items.each {|i| i.prepare}
      end

      private

      def menu_loop
        while @running do
          update_surface
          update_selector_movement
          read_events
        end
      end

      def read_events
        RUDL::EventQueue.get.each do |event|
          if event.kind_of? KeyDownEvent then
            case event.key
            when K_UP
              # select_previous
              @move = UP
              @last_movement_time = 0
            when K_DOWN
              # select_next
              @move = DOWN
              @last_movement_time = 0
            when K_LEFT
               selected_item.less
            when K_RIGHT
              selected_item.more
            when K_RETURN, K_SPACE
              selected_item.enter
            when K_ESCAPE
              quit
            end
          elsif event.kind_of? KeyUpEvent then
            case event.key
            when K_UP, K_DOWN
              @move = NO
            end
          elsif event.kind_of? MouseMotionEvent then
            if i = i_item_on_pos(event.pos) then
              select i
            end
          elsif event.kind_of? MouseButtonDownEvent then
            selected_item.enter
          end
        end
      end
      
      def update_surface
        @surface.fill BACKGROUND_COLOUR, @update_rect

        # blit menu title
        @surface.blit @image, [@x, @y]

        # paint menu items
        y = @y + @image.h + TITLE_MARGIN_BOTTOM
        @menu_items.each_index do |i|
          item = @menu_items[i]
          item.paint(@surface, [@x, y])

          if i == @selected then
            @surface.blit(@selector, [@x, y])
          end

          y = y + item.height
        end

        @surface.flip
      end

      # Method for continuous movemnt of the selector while user
      # keeps arrow key pressed

      def update_selector_movement
        return if @move == NO
        return if (Time.now.to_f - @last_movement_time) < DELAY

        case @move
        when UP
          select_previous
        when DOWN
          select_next
        end

        @last_movement_time = Time.now.to_f
      end

      def create_image(text)
        text_renderer.create_text_box(width, text)
      end

      def create_selector
        selector = RUDL::Surface.new [@width, @text_renderer.font.h]
        selector.fill SELECTOR_COLOUR
        selector.set_alpha 150

        return selector
      end

      def selected_item
        @menu_items[@selected]
      end

      # pos is an Array [x,y].
      # Returns index of item on that pos or nil.
      # Considers just y, not x

      def i_item_on_pos(pos)
        y = @y + @image.h + TITLE_MARGIN_BOTTOM
        return nil if pos[1] < y

        @menu_items.each_index do |i|
          item = @menu_items[i]
          y += item.height
          if pos[1] < y then
            return i
          end
        end

        return nil
      end
    end
  end
end
