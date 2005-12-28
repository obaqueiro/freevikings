# maploaderfactory.rb
# igneus 15.12.2005

=begin
= NAME
LocationLoaderFactory

= DESCRIPTION
Class (({MapLoaderFactory})) realizes the design pattern known as
'Abstract Factory'. It provides a transparent mechanism of getting
the right (({MapLoadStrategy})) subclasse's instance to load
any given location data.

= Superclass
Object
=end

require 'xmlmaploadstrategy.rb'
require 'tiledmaploadstrategy.rb'
require 'log4r'

module FreeVikings

  class MapLoaderFactory

    STRATEGIES = {"xml" => XMLMapLoadStrategy,
                  "tmx" => TiledMapLoadStrategy}

=begin
--- MapLoaderFactory.loader_for(file)
Returns the right loader to load the map data stored in file
((|file|)) (given a file name).
=end

    def MapLoaderFactory.loader_for(file)
      log = Log4r::Logger['location loading log']

      STRATEGIES.each_key do |suffix|
        r = suffix+'$'
        suffix_regex = Regexp.new(r)

        if file =~ suffix_regex then
          log.info "Creating loader of type #{STRATEGIES[suffix]} for file '#{file}'."
          return STRATEGIES[suffix].new(File.open(file))
        end
      end

      msg = "No MapLoad strategy available for file '#{file}'."
      log.error msg
      raise msg
    end
  end # class MapLoaderFactory
end # module FreeVikings
