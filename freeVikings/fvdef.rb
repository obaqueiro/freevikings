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

  WIN_WIDTH = 640
  WIN_HEIGHT = 480

  CODE_DIRS = ['monsters', 'ext'] # directories with additional source files
  DEFAULT_LEVELSET_DIR = 'locs/DefaultCampaign'

  LOCATION_PASSWORD_LENGTH = 4

  # Options defaults:
  OPTIONS['freevikings_home'] = '.'
  OPTIONS['levelset'] = DEFAULT_LEVELSET_DIR
  OPTIONS['velocity_unit'] = 1
  OPTIONS['delay'] = 0

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

=begin
--- FreeVikings.valid_location_password?(password)
Says if a ((|password|)) is a valid location password.
=end

  def FreeVikings.valid_location_password?(password)
    # valid location password must be 4 characters long and may
    # only contain word characters and digits
    password.size == FreeVikings::LOCATION_PASSWORD_LENGTH and 
      password =~ /^[\d\w]+$/
  end

end
