# menu.rb
# igneus 3.9.2005

require 'RUDL'
require 'menuitem.rb'

module GameUI
  module Menus

=begin
= GameUI::Menus
== Menu
((<Menu>)) is a container of special objects - instances of class
(({MenuItem})).
((<Menu>)) is a subclass of (({MenuItem})) itself so you can build nested 
structures and deep trees of ((<Menu>))s.

Call ((<Menu#run>)) and let the ((<Menu>)) interact with the user on it's
own. 

By creating subclasses of (({MenuItem})) you can make new buttons, switches
etc. which would behave according to your wishes.
Use them to let the user configure the game, start or quit it.
=end

    class Menu < MenuItem

      include RUDL
      include RUDL::Constant

      TITLE_MARGIN_BOTTOM = 20

      BACKGROUND_COLOUR = [0, 0, 0]
      SELECTOR_COLOUR = [236, 236, 0]

      DEFAULT_X = 100
      DEFAULT_Y = 50
      DEFAULT_WIDTH = 300

=begin
--- Menu#initialize(parent, title, surface, text_renderer, x=DEFAULT_X, y=DEFAULT_Y, width=DEFAULT_WIDTH)
Creates a new ((<Menu>)) as a child of ((|parent|)). If you want the newly 
created ((<Menu>)) to be a top-level ((<Menu>)), give ((|nil|)) as a first
argument.
((|title|)) must be a (({String})). Argument ((|surface|)) is 
a (({RUDL::Surface})) onto which the ((<Menu>)) will paint it's contents.
Parameter ((|text_renderer|)) must be a (({GameUI::TextRenderer})) instance.
=end

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
      end

=begin
--- Menu#text_renderer
=end

      attr_reader :text_renderer

=begin
--- Menu#width
=end

      attr_reader :width

=begin
--- Menu#x
=end

      attr_reader :x

=begin
--- Menu#y
=end

      attr_reader :y

=begin
--- Menu#surface
=end

      attr_reader :surface

=begin
--- Menu#enter
=end

      def enter
        self.run
      end

=begin
--- Menu#run
Gives the control to the ((<Menu>)) which then starts painting itself
and reading the events from (({RUDL::EventQueue})).
=end

      def run
        @selected = 0
        @running = true

        prepare

        menu_loop
      end

=begin
--- Menu#quit
Unless it's a top-level ((<Menu>)) our ((<Menu>)) gives control to it's
parent. Otherwise it stops running.
=end

      def quit
        @running = false
        @parent.run if @parent
      end

=begin
--- Menu#add(menu_item)
Adds a new item into the ((<Menu>)).
You don't usually need to call this method, it is called from inside 
of the added item's constructor.
=end

      def add(menu_item)
        @menu_items.push menu_item
      end

=begin
--- Menu#select_next
Moves the selector (the selection bar) onto the next item of the ((<Menu>))..
=end

      def select_next
        @selected += 1
        @selected = 0 if @selected >= @menu_items.size
      end

=begin
--- Menu#select_previous
Moves the selector back.
=end

      def select_previous
        @selected -= 1
        @selected = @menu_items.size - 1 if @selected < 0
      end

=begin
--- Menu#running?
Says if the ((<Menu>)) has the control now.
=end

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
          read_events
        end
      end

      def read_events
        RUDL::EventQueue.get.each do |event|
          if event.kind_of? KeyDownEvent then
            case event.key
            when K_UP
              select_previous
            when K_DOWN
              select_next
            when K_LEFT
              selected_item.less
            when K_RIGHT
              selected_item.more
            when K_RETURN, K_SPACE
              selected_item.enter
            end
          end
        end
      end
      
      def update_surface
        @surface.fill BACKGROUND_COLOUR, @update_rect

        @surface.blit @image, [@x, @y]

        @menu_items.each_index do |i|
          item = @menu_items[i]
          y = @y + @image.h + TITLE_MARGIN_BOTTOM + i*@image.h
          item.paint(@surface, [@x, y])
          
          if i == @selected then
            @surface.blit(@selector, [@x, y])
          end
        end

        @surface.flip
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
    end
  end
end
