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

  # sizes of the game window
  WIN_WIDTH = 640
  WIN_HEIGHT = 480

  # maximum fps
  FRAME_LIMIT = 20

  DEFAULT_LEVELSUITE_DIR = 'locs/DefaultCampaign'
  DEFAULT_THEME_DIR = GFX_DIR+'/themes'

  USERS_CONFIGURATION_FILE_NAME = 'config.rb'

  TESTED_LIB_VERSIONS = {
    'RUDL' => '0.7.1.0',
    'REXML' => '3.1.7.2'}

  # gravity (in pixels per second**2)
  # (most objects ignore it)
  GRAVITY = 30

  # array of campaigns;
  # each entry is a pair title=>path
  CAMPAIGNS = {}

  # Object which contains configuration
  # CONFIG = Configuration.new('config/structure.conf')

  # get the version number (as String)
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
