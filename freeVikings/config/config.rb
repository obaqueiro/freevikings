# config.rb
#
# Sample user's configuration file with descriptive comments.
# If you want to customise freeVikings, create directory '.freeVikings'
# in your $HOME directory, copy this file there and modify it according
# to your preferences.

# == Configuration file is Ruby script.
#
# Please, note, that this file is and must be a valid Ruby script.
# After modifying it it might be helpful to run
# $ ruby ~/.freeVikings/config.rb
# to ensure that you haven't made any syntax error etc.
#
# You can place any Ruby expressions here. The only one which is important
# for freeVikings is definition of constant CONFIG, which is a Hash
# of Hashes:
#
# CONFIG = {'Files' => {}, 'Video' => {}, 'Audio' => {}, 'Game' => {}, 'Controls' => {}, 'Development' => {}}

# == Some basics of Ruby for non-rubyists
#
# Sharp (#) starts a comment - you can use it to comment-out lines
# which Ruby shouldn't process, but you don't want to lose them.
# 
# Ruby Hash consists of pairs key => value divided by commas and embraced
# by braces.
# {} means empty Hash.
# {'value 1' => 1020, 'value 2' => 1560} is a Hash containing two pairs.
#
# Text closed in single or double quotes is Ruby String. All keys in Hash
# CONFIG are Strings.
#
# [] means empty Array. Array is a simple list of values.
# [1020, 1560, 'some text', "another text"]
#
# true and false are special constants for boolean values.
#
# Words with colon at the beginning (:symbol, :another_symbol, :baleog)
# are Symbols. Where a Symbol is required, follow exactly what the comment 
# says.

# == Configuration

CONFIG = {

  # === Files

  'Files' => {

    # Array of directories whose subdirectories will be treated as
    # campaign directories.
    #
    # Value: Array of Strings
    #
    # E.g. if you have made two campaigns placed in /home/you/fV/DesertCampaign
    # and /home/you/fV/CampaignMars, add '/home/you/fV' here and your
    # campaigns will be always prepared when you start freeVikings.
    'dirs with campaigns' => ['locs'],

    # Name of campaign which should be played by default.
    #
    # Value: String
    'default campaign' => 'Default Campaign',

    # Where directories gfx/ and music/ are
    #
    # Value: String (valid path!)
    'media' => '.'
  },

  # === Video

  'Video' => {

    # Value: true or false
    #
    # true = fullscreen mode
    # false = windowed mode
    'fullscreen' => false,

    # Where should panel with vikings' status (faces, inventories, energy)
    # be placed?
    #
    # Value: one of :bottom, :top, :left, :right
    'panel placement' => :bottom,

    # Should a progressbar be shown while loading new level?
    # (Sometimes progressbar causes infinite loading due to internal problem
    # called 'thread starvation', so if freeVikings load forever, try to
    # set this to false.)
    #
    # Value: true or false
    'loading progressbar' => true,

    # Should main menu be used?
    # (Set this to false only if you are annoyed by main menu because you
    # set everything up by configuration file and/or commandline options.)
    #
    # Value: true or false
    'menu' => true,

    # Show number of frames per second in the game window.
    #
    # Value: true or false
    'display FPS' => false
  },

  # === Audio

  'Audio' => {

    # Enable music?
    #
    # Value: true or false
    'music enabled' => true,

    # Volume of music.
    #
    # Value: real number from range 0.0 .. 1.0
    'music volume' => 1.0
  },

  # === Game

  'Game' => {

    # In which order should the vikings appear in the game?
    #
    # Value: Array with Strings 'Erik', 'Baleog', 'Olaf' in the desired
    # order
    'order of vikings' => ['Erik', 'Baleog', 'Olaf'],

    # If level password should be shown at the beginning of level in a black
    # box as in classic Lost Vikings. 
    # It is important to know the password to be able to play any reached level
    # sometimes later without having to playing again from the beginning.
    #
    # Value: true or false
    'show level password' => true,

    # How many times should Vikings' base speed be multiplied.
    # (Use this if the game is too slow for you.)
    #
    # Value: any number (higher than 3 or 4 makes game unplayable)
    'game speed' => 1,

    # Seconds to sleep in every frame.
    # (Set this to 0.010 or 0.020 if freeVikings
    # have fps higher then 20 and vikings move suspiciously slowly)
    #
    # Value: any number between 0 and 0.10
    'frame delay' => 0,
  }
}
