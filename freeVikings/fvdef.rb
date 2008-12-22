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

  DEFAULT_LEVELSUITE_DIR = 'locs/DefaultCampaign'
  DEFAULT_THEME_DIR = 'gfx/themes'

  TESTED_LIB_VERSIONS = {
    'RUDL' => '0.7.0.0',
    'REXML' => '3.1.3'}

  # gravity (in pixels per second**2)
  # (most objects ignore it)
  GRAVITY = 30

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
  # Show animated progressbar while loading?
  OPTIONS['progressbar_loading'] = true
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

  # caption of game window
  WIN_CAPTION = 'freeVikings ' + FreeVikings::VERSION

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

  # checks if all main libs have tested version.
  # Makes use of Ruby's relativelly intelligent string-comparations

  def FreeVikings.lib_versions_check
    # RUDL
    rudl_v = RUDL.versions['RUDL'].to_s
    if rudl_v < TESTED_LIB_VERSIONS['RUDL'] then
      STDERR.puts "Warning: Your RUDL version (#{rudl_v}) is older than latest version tested with freeVikings (#{TESTED_LIB_VERSIONS['RUDL']}). If you encounter problems with RUDL while you're playing, consider upgrading."
    elsif rudl_v > TESTED_LIB_VERSIONS['RUDL'] then
      STDERR.puts "Warning: Your RUDL version (#{rudl_v}) is newer than latest version tested with freeVikings (#{TESTED_LIB_VERSIONS['RUDL']}). Report any problems you may encounter."
    end

    # REXML
    rexml_v = REXML::Version
    if rexml_v < TESTED_LIB_VERSIONS['REXML'] then
      STDERR.puts "Warning: Your REXML version (#{rexml_v}) is older than latest version tested with freeVikings (#{TESTED_LIB_VERSIONS['REXML']}). If you encounter problems with REXML while you're playing, consider upgrading."
    elsif rexml_v > TESTED_LIB_VERSIONS['REXML'] then
      STDERR.puts "Warning: Your REXML version (#{rexml_v}) is newer than latest version tested with freeVikings (#{TESTED_LIB_VERSIONS['REXML']}). Report any problems you may encounter."
    end
  end
end
