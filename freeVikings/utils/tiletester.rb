#!/usr/bin/ruby -w

# tiletester.rb
# igneus 22.9.2005

# An utility for tiles test.
# It's designed for the location designers to test the developed
# tiles quickly and effectively.

# Unless 'freeVikings/util' is the working directory,
# 'freeVikings' must be added into the features path.
if `pwd` != File.dirname(__FILE__) then
  $: << File.dirname(File.dirname(__FILE__))
end

require 'model.rb'
require 'RUDL'
require 'optparse'

class TileTester

  include FreeVikings
  include RUDL

  TS = TILE_SIZE = 40

  def initialize(surface, width, height, files)
    @surface = surface
    @width = width
    @height = height
    @files = files
    @images = []
    load_images
  end

  def run
    loop do
      repaint
      read_events
      sleep 1.2
    end
  end

  private

  def repaint
    @surface.blit @img, [0,0]
    @surface.flip
  end

  def read_events
    events = EventQueue.get

    events.each do |event|
      exit if event.kind_of? QuitEvent
      load_images if event.is_a? MouseButtonDownEvent
    end
  end

  def paint(surface)
    tile_num = 0
    0.upto(@height - 1) do |line|
      0.upto(@width - 1) do |column|
        tile_surface = @images[tile_num % @images.size].image
        surface.blit(tile_surface, [column * TS, line * TS])
        tile_num += 1
      end
    end
  end

  def load_images
    @images.clear

    @files.each do |f|
      @images << Image.new(f)
    end

    @img = Surface.new([@surface.w, @surface.h])
    paint(@img)
  end
end

if $0 == __FILE__ then
  width = height = 2

  option_parser = OptionParser.new do |opts|
    opts.on("-w", "--width WIDTH", Integer, "Make the tester WIDTH tiles wide.") do |w|
      width = w
    end
  
    opts.on("-h", "--height HEIGHT", Integer, "Make the tester HEIGHT tiles high") do |h|
      height = h
    end
  end

  option_parser.parse!(ARGV)

  win = RUDL::DisplaySurface.new([width*40, height*40])
  TileTester.new(win, width, height, ARGV).run
end
