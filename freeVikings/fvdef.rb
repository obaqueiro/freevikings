# fvdef.rb
# igneus 3.8.2005

# First definition of the module FreeVikings

###############################################################################
# This file must be required only once - from the top level!                  #
# (from freevikings.rb or tests/test.rb)                                      #
###############################################################################

# All the game's globals and classes are defined inside this module.
module FreeVikings
  GFX_DIR = 'gfx' # directory with graphics
  OPTIONS = {} # hash with long options as keys

  # main application window sizes
  WIN_WIDTH = 640
  WIN_HEIGHT = 480

  CODE_DIRS = ['monsters', 'ext'] # directories with additional source files
  DATA_DIR = 'locs' # directory with location data

  # get the version number
  if File.exist?('RELEASE')
    File.open('RELEASE') do |fr|
      FreeVikings::VERSION = fr.gets.chomp
    end
  else
    FreeVikings::VERSION = 'DEV'
  end

  FONTS = {} # a hash of fonts
end
