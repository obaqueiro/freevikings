#!/usr/bin/ruby -w

# animationtester.rb
# igneus 12.9.2005

# An utility which loads all the given filenames as images and displays 
# them as animation.

# Unless 'freeVikings/util' is the working directory,
# 'freeVikings' must be added into the features path.
if `pwd` != File.dirname(__FILE__) then
  $: << File.dirname(File.dirname(__FILE__))
end

require 'RUDL'

require 'images.rb'

class AnimationTester

  include FreeVikings

  def initialize(surface, delay, *filenames)
    @surface = surface

    @anim = Animation.new(delay)
    filenames.each {|f| @anim.add(Image.new(f)) }

    img = @anim.image
    @pos = [surface.w/2 - img.w/2, surface.h/2 - img.h/2]
  end

  def run
    loop do
      if RUDL::EventQueue.get.find {|event| 
          event.kind_of? RUDL::KeyDownEvent or event.kind_of? RUDL::QuitEvent
        }
        break
      end

      @surface.fill [0,0,0]
      @surface.blit @anim.image, @pos
      @surface.flip
    end
  end
end

if __FILE__ == $0 then
  win = RUDL::DisplaySurface.new [200,200]
  win.set_caption 'Animation Tester'

  AnimationTester.new(win, 1, *ARGV).run
end
