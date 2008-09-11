# locationloader.rb
# igneus 24.12.2005

=begin
= NAME
LocationLoader

= DESCRIPTION
(({LocationLoader})) gets information about location data from XML file
and provides data to the (({Location})) object.
=end

require 'rexml/document'

require 'locationscript.rb'
require 'maploaderfactory.rb'

module FreeVikings

  class LocationLoader

    DEFAULT_START_POINT = [5,5]
    DEFAULT_EXIT_POINT  = [100,100]

=begin
--- LocationLoader#new(source)
Argument ((|source|)) must be a valid argument to (({REXML::Document.new})).
It should contain a valid location definition.
=end

    def initialize(source)
      @log = Log4r::Logger['world log']

      @source = source

      if @source.respond_to? :path then
            @dir = File.dirname(@source.path)
      else
        @dir = ''
      end

      @doc = REXML::Document.new @source

      get_private_info
      publish_info
    end

    attr_reader :title
    attr_reader :author
    attr_reader :password
    attr_reader :start
    attr_reader :exit

=begin
--- LocationLoader#load_map(blocks_matrix)
Feeds ((|blocks_matrix|)) (expected to be an (({Array}))) by (({Array}))s
of (({Tile})) instances.
=end

    def load_map(blocks_matrix)
      map_file = @dir+'/'+@map_file
      @log.info "Loading map from file '#{map_file}'"
      MapLoaderFactory.loader_for(map_file).load(blocks_matrix)
    end

=begin
--- LocationLoader#load_script(location)
Adds into ((|location|)) monsters and other in-game objects if any supplied
for the location being loaded.
=end

    def load_script(location)
      unless @script
        @log.warn "No script to load."
        return
      end

      scriptfile = @dir+'/'+@script

      if @script == "" then
        @log.warn "No location script found."
        return
      end

      @log.info "Loading monsters from script #{scriptfile}"

      # Pri nahravani skriptu muze nastat velke mnozstvi vyjimecnych situaci:
      begin
        s = LocationScript.new(scriptfile) {|script| 
          script.extend FreeVikings
          script.extend SchwerEngine

          script.module_eval {
            alias_method :_require, :require
          }

          eval "script::LOCATION = location"
        }
      rescue StandardError => ex
        # Construct an error message.
        # Backtrace is cut so that it ends on the scriptfile (doesn't continue
        # through the stack of core-methods-calls)
        msg = "#{ex.class} in script '#{scriptfile}': #{ex.message}"
        scriptfile_regex = Regexp.new scriptfile
        begin
          n = ex.backtrace.shift
          msg += "\t" + n + "\n"
        rescue TypeError
          # scriptfile not found in backtrace. It's a pity, but...
          break
        end while not (n =~ scriptfile_regex)
        msg.chop! # chop the last '\n' which is superfluous

        @log.error msg
      else
        @log.info "Script '#{scriptfile}' successfully loaded."
      end
    end

=begin
--- LocationLoader#load_exit(location)
Adds (({Exit})) into ((|location|)).
=end

    def load_exit(location)
      location.exitter = Exit.new(@exit)
    end

=begin
--- LocationLoader#load_start(location)
Supplies ((|location|)) information about where to place vikings 
on the beginning of game.
=end

    def load_start(location)
      location.start = @start
    end

    private

    # Gets from @doc and "publishes" (loads into public attributes)
    # data from the definition file. Doesn't load any additional data.

    def publish_info
      @title = @doc.root.elements['info'].elements['title'].text
      @author = @doc.root.elements['info'].elements['author'].text
      @password = @doc.root.elements['body'].elements['password'].text

      strt = @doc.root.elements['body'].elements['start']
      @start = [strt.attributes['horiz'].to_i,
                strt.attributes['vertic'].to_i]

      exit = @doc.root.elements['body'].elements['exit']
      @exit = [exit.attributes['horiz'].to_i,
               exit.attributes['vertic'].to_i]
    end

    # Gets private info from @doc

    def get_private_info
      # map file name:
      begin
        @map_file = @doc.root.elements['body'].elements['map'].\
        attributes['src']
      rescue
        @log.fatal "Location does not have a map file. Crashing."
        raise
      end

      # script file name:
      begin
        @script = @doc.root.elements['body'].elements['script'].\
        attributes['src']
      rescue
        @log.warn "Location does not have any script file."
        @script = nil
      end
    end
  end # class LocationLoader
end # module FreeVikings
