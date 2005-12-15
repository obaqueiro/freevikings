# locationloaderfactory.rb
# igneus 15.12.2005

=begin
= NAME
LocationLoaderFactory

= DESCRIPTION
Class (({LocationLoaderFactory})) realizes the design pattern known as
'Abstract Factory'. It provides a transparent mechanism of getting
the right (({LocationLoadStrategy})) subclasse's instance to load
any given location data.

= Superclass
Object
=end

require 'xmllocationloadstrategy.rb'
require 'tiledlocationloadstrategy.rb'
require 'log4r'

module FreeVikings

  class LocationLoaderFactory

    STRATEGIES = {"xml" => XMLLocationLoadStrategy,
                  "tmx" => TiledLocationLoadStrategy}

=begin
--- LocationLoaderFactory.loader_for(directory)
Returns the right loader to load the location data stored in directory
((|directory|)) (given a directory name).
=end

    def LocationLoaderFactory.loader_for(directory)
      log = Log4r::Logger['location loading log']

      log.info "Searching directory #{directory} for location data."
      d = Dir.open directory
      
      STRATEGIES.each_key do |suffix|
        r = suffix+'$'
        log.debug "Looking for file with suffix #{suffix}..."
        suffix_regex = Regexp.new(r)

        d.rewind
        d.each do |f| 
          if f =~ suffix_regex then
            log.info "Found location data file #{f}."
            log.info "Creating loader of type #{STRATEGIES[suffix]}."
            return STRATEGIES[suffix].new(File.open(directory+'/'+f))
          end
        end
      end

      msg = "No location data found in directory #{directory}."
      log.error msg
      raise msg
    end
  end # class LocationLoaderFactory
end # module FreeVikings
