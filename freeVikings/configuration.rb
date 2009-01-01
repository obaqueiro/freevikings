# configuration.rb
# igneus 31.12.2008

require 'script'

module FreeVikings

  class Configuration

    def initialize(structure_filename)
      @log = Log4r::Logger['init log']

      @structure = Configuration.load_structure(structure_filename)

      # this Hash contains entries in sub-Hashes of categories
      @categories = empty_structure()
      # and this Hash offers direct access to them, without categories
      @values = {}
    end

    # Loads structure from file and returns it.

    def Configuration.load_structure(filename)
      config_script = Configuration.script(filename)

      return config_script::CONFIG
    end

    def Configuration.load_empty_structure(filename)
      s = Configuration.load_structure filename

      h = {}
      s.keys.each {|cat|
        h[cat] = {}
      }
      return h
    end

    # Call this method as many times as you want. It loads values from a given
    # configuration file and rewrites those already set.

    def load(filename)
      s = Configuration.script(filename)
      c = s::CONFIG
      load_hash c
    end

    # Loads configuration from Hash

    def load_hash(c)
      c.each_pair do |cat_name, cat_hash|
        next unless validate_category(cat_name)

        cat_hash.each_pair do |entry, value|
          next unless validate_entry(cat_name, entry, value)

          @categories[cat_name][entry] = value
          @values[entry] = value
        end
      end
    end

    # Use this method to access entries.

    def [](index)
      if @categories.has_key?(index) then
        return @categories[index]
      elsif @values.has_key?(index) then
        return @values[index]
      else
        raise ArgumentError, "Unknown key '#{index}'"
      end
    end

    private

    # Loads script and performs some basic checks

    def Configuration.script(filename)
      config_script = Script.new(filename)
      unless config_script.const_defined?(:CONFIG)
        raise ArgumentError, "Configuration script '#{filename}' doesn't define constant CONFIG."
      end
      return config_script
    end

    def validate_category(cat_name)
      unless @structure.keys.include? cat_name
        @log.error "Unknown category '#{cat_name}'."
        return false
      end

      return true
    end

    # Only entries of validated categories will be successfully processed, 
    # others will cause unpredictable behavior!

    def validate_entry(category, entry, value)
      unless @structure[category].has_key?(entry)
        @log.error "Unknown entry '#{entry}' in category '#{category}'"
        return false
      end
      
      condition = @structure[category][entry]
      if condition.is_a? Class then
        unless value.is_a? condition
          @log.error "Wrong type '#{value.class}' for entry '#{entry}' in category '#{category}' (must be '#{condition}')"
          return false
        end
      elsif condition.is_a? Array then
        unless condition.include? value
          @log.error "Wrong value '#{value}' for entry '#{entry}' in category '#{category}' (must be one of '#{condition.inspect}')"
          return false
        end
      else
        raise "Unknown condition type '#{condition.type}' for entry '#{entry}' in category '#{category}' - configuration structure is badly defined! Lynch the developers!"
      end

      return true
    end

    # Returns empty copy of configuration hash structure

    def empty_structure
      h = {}
      @structure.keys.each {|cat|
        h[cat] = {}
      }
      return h
    end
  end
end

if __FILE__ == $0 then
  require 'mocklog4r'
  require 'pp'

  c = FreeVikings::Configuration.new './config/structure.conf'

  c.load './config/defaults.conf'
  c.load '/home/igneus/.freeVikings/config.rb'

  pp c
end
