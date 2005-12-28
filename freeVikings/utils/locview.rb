#!/usr/bin/ruby -w

# locview.rb
# Location browser designed as a development tool (it's also a powerfull
# cheating tool)

$:.push(File.expand_path('..'))

module FreeVikings
  GFX_DIR = File.expand_path 'gfx'
  OPTIONS = {}
end

require 'RUDL'
require 'log4r'

require 'log4rsetupload' # nastaveni log4r

require 'map'
require 'location'
require 'xmllocationloadstrategy'

require 'sprite'; require 'monster'

require 'alternatives'

class NonScriptLocationLoadStrategy < FreeVikings::XMLMapLoadStrategy
  def load_monsters(location)
  end
end

class Browser

  VIEW_MOVE = 10
  VIEW_SIZE = {'h' => 640, 'v' => 480}
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
    @loc = Location.new(XMLMapLoadStrategy.new(location_path))
    self.win_caption = TITLE + ': ' + File.basename(location_path)
    @view_center = [VIEW_SIZE['h']/2, VIEW_SIZE['v']/2] # stred zobrazovane oblasti mapy
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
    RUDL::EventQueue.get.each do |event|
      serve_event event
    end
    @loc.update
    @loc.paint @win, @view_center
    pos = mouse_position_in_location
    @win.print([10,10], "[#{pos[0]}, #{pos[1]}]", 0xFFFFFFFF)
    @win.flip
  end
	
  # Sets the display window's title

  def win_caption=(caption)
    @win.set_caption caption
  end

  private

  # Returns the position of the mouse relative to the topleft 
  # corner of the location

  def mouse_position_in_location
    winpos_to_locpos(RUDL::Mouse.pos)
  end

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
    if event.is_a? RUDL::MouseButtonDownEvent then
      if event.button == 1 then
        a = winpos_to_locpos(event.pos)
        puts 'clicked: h:' + a[0].to_s + ' v:' + a[1].to_s
      elsif event.button == 2 then
        pos = winpos_to_locpos(event.pos)
        @loc.sprites_on_rect(Rectangle.new(pos[0], pos[1], 1, 1)).each {|s| 
          s.hurt
        }
        @loc.active_objects_on_rect(Rectangle.new(pos[0], pos[1], 1, 1)).each {|o| 
          o.activate
        }
      end
    end
    if event.is_a? RUDL::QuitEvent then
      exit
    end
  end

  # Opens the display window

  def open_win
    @win = RUDL::DisplaySurface.new [VIEW_SIZE['h'], VIEW_SIZE['v']]
    self.win_caption = TITLE
  end

  private

  # Converts position in window onto the position in location

  def winpos_to_locpos(winpos)
    x = @view_center[0] - VIEW_SIZE['h']/2 + winpos[0]
    y = @view_center[1] - VIEW_SIZE['v']/2 + winpos[1]
    return [x,y]
  end
end

b = Browser.new
b.view ARGV[0]

puts 'Enjoy browsing...'

loop {
  b.update
}
