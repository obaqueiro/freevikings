#!/usr/bin/ruby -w
# locview.rb
# Location browser designed as a development tool (it's also a powerfull
# cheating tool)

$:.push(File.expand_path('..'))

require 'RUDL'

require 'map'
require 'location'
require 'locationloadstrategy'

module FreeVikings
  GFX_DIR = File.expand_path 'gfx'
end

class NonScriptLocationLoadStrategy < FreeVikings::XMLLocationLoadStrategy
  def load_monsters(location)
  end
end

class Browser

  VIEW_MOVE = 2
  TITLE = 'freeVikings Location Browser'

  include FreeVikings
  include RUDL::Constant

  def initialize
    puts 'Creating a new location browser.'
    open_win
    @loc = nil
  end

  # loads a specified location file
	
  def view(location_path)
    @path = location_path
    @loc = Location.new(NonScriptLocationLoadStrategy.new(location_path))
    self.win_caption = TITLE + ': ' + File.basename(location_path)
    @view_center = [150,150] # stred zobrazovane oblasti mapy
    @center_move = [0,0] # rychlost pohybu h i v smeru
  end

  # reloads the loaded location

  def review
    view(@path)
  end

  # Updates view
	
  def update
    @view_center[0] += @center_move[0]
    @view_center[1] += @center_move[1]
    serve_event RUDL::EventQueue.poll
    @loc.paint @win, @view_center
    @win.flip
  end
	
  # Sets the display window's title

  def win_caption=(caption)
    @win.set_caption caption
  end

  private

  # Serves event
	
  def serve_event(event)
    if event.is_a? RUDL::KeyDownEvent then
      case event.key
      when K_q
	puts 'Quit event - Good bye!'
	exit
      when K_r
	self.review
      when K_UP
	@center_move[1] = - VIEW_MOVE
      when K_DOWN
	@center_move[1] = VIEW_MOVE
      when K_LEFT
	@center_move[0] = - VIEW_MOVE
      when K_RIGHT
	@center_move[0] = VIEW_MOVE
      when K_PAGEUP
	@view_center[1] -= @win.h
      when K_PAGEDOWN
	@view_center[1] += @win.h
      when K_HOME
	@view_center[0] = @win.w / 2
      when K_END
	@view_center[0] = @loc.background.w - (@win.w / 2)
      end
    end
    if event.is_a? RUDL::KeyUpEvent then
      case event.key
      when K_UP, K_DOWN
	@center_move[1] = 0
      when K_LEFT, K_RIGHT
	@center_move[0] = 0
      end
    end
    if event.is_a? RUDL::QuitEvent then
      exit
    end
  end

  # Opens the display window

  def open_win
    @win = RUDL::DisplaySurface.new [300,300]
    self.win_caption = TITLE
  end
end

b = Browser.new
b.view ARGV[0]

puts 'Enjoy browsing...'

loop {
  b.update
}
