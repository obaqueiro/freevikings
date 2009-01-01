# configuration.rb
# igneus 31.12.2008

require 'script'

module FreeVikings

  class Configuration

    def initialize(structure_filename)
      @log = Log4r::Logger['init log']

      @structure_filename = structure_filename

      @structure = Configuration.load_structure(structure_filename)

      # this Hash contains entries in sub-Hashes of categories
      @categories = empty_structure()
      # and this Hash offers direct access to them, without categories
      @values = {}

      # While loading a configuration script it's name is temporarily assigned
      # to this variable (so that every method can see it and e.g. include
      # it in logging message)
      @loading_file = nil
    end

    # Loads structure from file and returns it.

    def Configuration.load_structure(filename)
      @loading_file = filename
      config_script = Configuration.script(filename)
      @loading_file = nil
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
      @loading_file = filename
      begin
        s = Configuration.script(filename)
        c = s::CONFIG
        load_hash c
      rescue SyntaxError => se
        @log.error "SyntaxError in configuration script '#{@loading_file}': "+se.message
        @log.error "configuration script '#{@loading_file}' could not be loaded."
      end
      @loading_file = nil
    end

    # Loads configuration from Hash

    def load_hash(c)
      @loading_file = "hash" unless @loading_file
      c.each_pair do |cat_name, cat_hash|
        next unless validate_category(cat_name)

        cat_hash.each_pair do |entry, value|
          next unless validate_entry(cat_name, entry, value)

          @categories[cat_name][entry] = value
          @values[entry] = value
        end
      end
      @loading_file = nil if @loading_file == 'hash'
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
        @log.error "configuration script #{@loading_file}: Unknown category '#{cat_name}'."
        return false
      end

      return true
    end

    # Only entries of validated categories will be successfully processed, 
    # others will cause unpredictable behavior!

    def validate_entry(category, entry, value)
      unless @structure[category].has_key?(entry)
        @log.error "configuration script #{@loading_file}: Unknown entry '#{entry}' in category '#{category}'"
        return false
      end
      
      condition = @structure[category][entry]
      if condition.is_a? Class then
        unless value.is_a? condition
          @log.error "configuration script #{@loading_file}: Wrong type '#{value.class}' for entry '#{entry}' in category '#{category}' (must be '#{condition}')"
          return false
        end
      elsif condition.is_a? Array then
        unless condition.include? value
          @log.error "configuration script #{@loading_file}: Wrong value '#{value}' for entry '#{entry}' in category '#{category}' (must be one of '#{condition.inspect}')"
          return false
        end
      elsif condition.is_a? Proc then
        unless condition.call(value)
          @log.error "configuration script #{@loading_file}: condition failed for value '#{value}' of entry '#{entry}' in category '#{category}'"
          return false
        end
      else
        raise "Unknown condition type '#{condition.class}' for entry '#{entry}' in category '#{category}' - configuration structure loaded from file #{@structure_filename} is badly defined! Lynch the developers!"
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
