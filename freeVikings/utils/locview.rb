#!/usr/bin/ruby -w
# locview.rb
# Location browser designed as a development tool (it's also a powerfull
# cheating tool)

$:.push(File.expand_path('..'))

require 'RUDL'
require 'map'
require 'location'
require 'locationloadstrategy'

require 'sprite'

module FreeVikings
  GFX_DIR = File.expand_path 'gfx'
end

class Browser

  VIEW_MOVE = 2

  include FreeVikings
  include RUDL::Constant

  def initialize
    puts 'Creating a new location browser.'
    @win = RUDL::DisplaySurface.new [300,300]
    @loc = nil
  end
	
  def view(location_path)
    @loc = Location.new(XMLLocationLoadStrategy.new(location_path))
    @view_center = [150,150]
    @center_move = [0,0]
  end
	
  def update
    @view_center[0] += @center_move[0]
    @view_center[1] += @center_move[1]
    serve_event RUDL::EventQueue.poll
    @loc.paint @win, @view_center
    @win.flip
  end
	
  private
	
  def serve_event(event)
    if event.is_a? RUDL::KeyDownEvent then
      case event.key
      when K_q
	puts 'Quit event - Good bye!'
	exit
      when K_UP
	@center_move[1] = - VIEW_MOVE
      when K_DOWN
	@center_move[1] = VIEW_MOVE
      when K_LEFT
	@center_move[0] = - VIEW_MOVE
      when K_RIGHT
	@center_move[0] = VIEW_MOVE
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
  end
end

b = Browser.new
b.view ARGV[0]

puts 'Enjoy browsing...'

loop {
  b.update
}

exit
