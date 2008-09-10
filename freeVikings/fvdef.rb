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
  MUSIC_DIR = 'music'
  OPTIONS = {} # hash with long options as keys

  # sizes of the game window
  WIN_WIDTH = 640
  WIN_HEIGHT = 480

  CODE_DIRS = ['monsters', 'ext'] # directories with additional source files
  DEFAULT_LEVELSUITE_DIR = 'locs/DefaultCampaign'
  DEFAULT_THEME_DIR = 'gfx/themes'

  LOCATION_PASSWORD_LENGTH = 4

  # Options defaults:

  # Base directory searched for data directories
  OPTIONS['freevikings_home'] = '.'
  # Directory with data of the LevelSuite to be played
  OPTIONS['levelsuite'] = DEFAULT_LEVELSUITE_DIR
  # Directory with subdirectories of themes
  OPTIONS['theme_dir'] = DEFAULT_THEME_DIR
  OPTIONS['velocity_unit'] = 1
  # Delay (in milliseconds) in every iteration of the game loop
  OPTIONS['delay'] = 0
  # Show menu? (false = skip menu)
  OPTIONS['menu'] = true
  # Show password at the beginning of every level?
  OPTIONS['display_password'] = true
  # Use sound?
  OPTIONS['sound'] = true
  # Is "developer's magic" enabled or disabled?
  OPTIONS['develmagic'] = false

  # get the version number
  if File.exist?('RELEASE')
    File.open('RELEASE') do |fr|
      FreeVikings::VERSION = fr.gets.chomp
    end
  else
    FreeVikings::VERSION = 'DEV'
  end

  FONTS = {} # a hash of fonts

  # Module FreeVikings has a special querying feature.
  # You can get any value from the hash OPTIONS (which is used
  # to store configuration during the runtime) by calling
  # FreeVikings#key or FreeVikings#key? where key is a key
  # into the hash.
  # NoMethodError can occur unless the key is defined.
  def FreeVikings.method_missing(name, *args)
    key = (name.to_s =~ /.*\?/ ? 
           name.to_s.chop : name.to_s)

    unless defined?(FreeVikings::OPTIONS[key])
      raise NoMethodError, "Key #{key} undefined in FreeVikings::OPTIONS."
    end

    return FreeVikings::OPTIONS[key]
  end # FreeVikings.method_missing

  # Says if a ((|password|)) is a valid location password.
  # Valid location password must be 4 characters long and may
  # only contain word characters and digits.
  def FreeVikings.valid_location_password?(password)
    password.size == FreeVikings::LOCATION_PASSWORD_LENGTH and 
      password =~ /^[\d\w]+$/
  end

end
