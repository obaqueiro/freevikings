# schwerengine.rb
# igneus 28.10.2005

require 'log4r'

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
      config = File.dirname(__FILE__)+'/log4rconfig.xml'
      Log4r::Configurator.load_xml_file(config)
      Log4r::Logger.global.level = Log4r::OFF
    end

    # load classes; Some of them need some Log4r setup to be finished
    # before they are loaded so Log4r configuration must be done before
    # we come here.
    SchwerEngine.module_eval do

      # Basics
      require 'schwerengine/rect.rb'
      require 'schwerengine/gfxtheme.rb'
      require 'schwerengine/pausable.rb'
      require 'schwerengine/ticker.rb'
      require 'schwerengine/timelock.rb'
      
      # Graphics related stuff
      require 'schwerengine/image.rb'
      require 'schwerengine/animation.rb'
      require 'schwerengine/portrait.rb'
      require 'schwerengine/model.rb'

      # Entities
      require 'schwerengine/entity.rb'
      require 'schwerengine/sprite.rb'
      require 'schwerengine/item.rb'
      require 'schwerengine/activeobject.rb'
      require 'schwerengine/staticobject.rb'

      require 'schwerengine/hero.rb'
      require 'schwerengine/monster.rb'

      # Groups
      require 'schwerengine/group.rb'
      require 'schwerengine/selectivegroup.rb'
      require 'schwerengine/spritemanager.rb'
      
      # Maps & relatives
      require 'schwerengine/tile.rb'
      require 'schwerengine/map.rb'
      require 'schwerengine/location.rb'
      require 'schwerengine/nullocation.rb'
      require 'schwerengine/maploadstrategy.rb'

    end
  end
end



