# schwerengine.rb
# igneus 28.10.2005

# This is here because freeVikings load Log4r themselves and it is optional -
# if Log4r isn't installed on the system, mock Log4r is loaded instead.
unless defined?(Log4r) then
  require 'log4r'
end

unless defined?(RUDL) then
  require 'RUDL'
end



module SchwerEngine
  DISABLE_LOG4R_SETUP = 0001

  @@config = nil
  @@initialized = nil

  def SchwerEngine.config
    if @@config.nil? then
      raise "Configuration module hasn't been assigned yet."
    end

    @@config
  end

  def SchwerEngine.config=(c)
    if @@config.nil? then
      @@config = c
      SchwerEngine.module_eval { include @@config }
    else
      raise "SchwerEngine configuration module can be assigned only once during runtime."
    end
  end

  def SchwerEngine.init(flags=0)
    if @@initialized then
      raise "Framework SchwerEngine can be initialized only once during runtime."
    else
      @@initialized = true
    end

    # load Log4r setup
    unless (flags & DISABLE_LOG4R_SETUP) > 0
      require 'log4r/configurator'
      config = File.dirname(__FILE__)+'/schwerengine/log4rconfig.xml'
      Log4r::Configurator.load_xml_file(config)
      Log4r::Logger.global.level = Log4r::OFF
    end

    # load classes; Some of them need some Log4r setup to be finished
    # before they are loaded so Log4r configuration must be done before
    # we come here.
    SchwerEngine.module_eval do

      # Basics
      require_relative 'schwerengine/rect3.rb'
      # require_relative 'schwerengine/rect.rb' # parent of RelativeRect
      require_relative 'schwerengine/relativerect.rb'
      require_relative 'schwerengine/gfxtheme.rb'
      require_relative 'schwerengine/pausable.rb'
      require_relative 'schwerengine/ticker.rb'
      require_relative 'schwerengine/timelock.rb'
      
      # Graphics related stuff
      require_relative 'schwerengine/image.rb'
      require_relative 'schwerengine/animation.rb'
      require_relative 'schwerengine/portrait.rb'
      require_relative 'schwerengine/model.rb'
      require_relative 'schwerengine/spritesheet.rb'

      # Groups
      require_relative 'schwerengine/group.rb'
      require_relative 'schwerengine/selectivegroup.rb'
      require_relative 'schwerengine/spritemanager.rb'
      
      # Maps & relatives
      require_relative 'schwerengine/map.rb'
      require_relative 'schwerengine/maploadstrategy.rb'
      require_relative 'schwerengine/xmlmaploadstrategy.rb'
      require_relative 'schwerengine/tiledmaploadstrategy.rb'
    end
  end
end



