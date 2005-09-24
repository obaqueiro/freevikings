# rudlmore.rb
# igneus 24.9.2005

# Some features which I missed in RUDL

require 'RUDL'

module RUDL

  class DisplaySurface < Surface

    alias_method :classic_initialize, :initialize

    def initialize(sizes, flags=0, depth=0)
      @fullscreen = (flags & FULLSCREEN) ? true : false
      classic_initialize(sizes, flags, depth)
    end

    alias_method :classic_toggle_fullscreen, :toggle_fullscreen

    def toggle_fullscreen
      @fullscreen = ! @fullscreen
      classic_toggle_fullscreen
    end

    def fullscreen?
      @fullscreen
    end
  end
end # module RUDL
