# levelsuite.rb
# igneus 1.8.2005

require 'rexml/document'

# require 'level.rb' # this require command is at the end of the file because
# Level < LevelSuite

module FreeVikings

  # LevelSuite is a set of LevelSuites.

  class LevelSuite

    # Standard name of the XML file which contains the campaign's definition.

    DEFINITION_FILE_NAME = 'levelsuite.xml'

    # Standard name of the XML file which defines the graphics theme.

    THEME_FILE = 'theme.xml'

    # Argument dir is of type String. It is a name of the directory where
    # the file 'levelsuite.xml' for the loaded LevelSuite is.
    # If the LevelSuite is nested in some other LevelSuite, it's
    # given a second argument member_of, which is a 'parent' LevelSuite.

    def initialize(dirname, member_of=nil)
      @log = Log4r::Logger['world log']

      @log.debug "#{object_id}: Loading a new level suite from directory #{dirname}."

      @dirname = dirname
      @members = []
      @member_of = member_of

      # values are usually changed in method load_from_xml
      @title = ""
      @theme = nil
      @theme_name = ""

      # Not to be used in subclasses:
      if self.class == LevelSuite then
        if LevelSuite.is_levelsuite_directory?(dirname) then
          load_from_xml
        elsif Level.is_level_directory?(dirname) then
          @members << Level.new(dirname, self)
        else
          msg = "Directory '#{dirname}' doesn't contain any LevelSuite or Level definition."
          @log.error msg
          raise LevelSuiteLoadException, msg
        end
      end

      @log.debug "#{object_id}: New LevelSuite created from data in directory '#{@dirname}' as a nested suite in #{@member_of ? @member_of.object_id : @member_of.to_s}"
    end

    # Decides if directory is LevelSuite or Level directory
    # and returns LevelSuite or Level.
    # Use it only to create the top-level LevelSuite or Level -
    # (see e.g. StructuredWorld#initialize)
    # LevelSuite nesting is done elsewhere.

    def LevelSuite.factory(directory)
      if LevelSuite.is_levelsuite_directory? directory then
        return LevelSuite.new(directory)
      elsif Level.is_level_directory? directory then
        return Level.new(directory)
      else
        raise ArgumentError, "Directory '#{directory} doesn't contain neither LevelSuite or Level."
      end
    end

    # Says if specified directory contains the LevelSuite definition file.

    def LevelSuite.is_levelsuite_directory?(dirname)
      deffile = dirname+'/'+DEFINITION_FILE_NAME

      if File.exist?(deffile) then
        return true
      else
        return false
      end
    end

    # Returns a String with the name (usually a subpath) 
    # of the LevelSuite's directory.

    attr_reader :dirname

    # Returns name of LevelSuite/Level

    attr_reader :title

    # Returns an Array of LevelSuite objects 
    # (it means both LevelSuites and Levels).

    attr_reader :members

    # Returns an Array of Levels

    def levels
      a = []
      @members.each {|m|
        if m.is_a? Level then
          a << m
        else
          a += m.levels
        end
      }
      return a
    end

    # Returns next Level from the LevelSuite or nil if any more
    # Levels are available.
    #
    # (Implementation detail:
    # The Level objects aren't stored in the LevelSuite instance,
    # but are obtained by call to LevelSuite#next_level.)

    def next_level
#       unless @active_member
#         @active_member = @members.shift
#       end
      unless @active_member_i
        @active_member_i = 0
      end

      # This case occurs when an empty levelset directory
      # with a content-less levelsuite.xml file exists.
      if active_member.nil? then
        return nil
      end

      if (level = active_member.next_level).nil? then
        # The active levelset has no more levels.
        # Set another levelset active and try to get a level once more:
        @active_member_i += 1

        if active_member.nil? then
          return nil
        else
          return next_level
        end
      else
        return level
      end
    end

    # Returns a Level with password password and sets it active 
    # or throws LevelSuite::UnknownPasswordException if no such level
    # exists. For more information about passwords read documentation for class
    # StructuredWorld.

    def level_with_password(password)
      @log.debug "Asked for a level with password #{password}."

      while (level = next_level) do
        return level if level.password == password
      end
     
      @log.error "Level with password #{password} wasn't found."
      raise UnknownPasswordException, "Password #{password} doesn't exist."
    end

    # Returns a GfxTheme for the set of levels. (If there isn't such
    # GfxTheme, a NullGfxTheme is returned, but NullGfxTheme
    # behaves in the same way as normal GfxTheme, so you don't need to
    # worry about it.)

    def gfx_theme
      if @theme == nil then
        msg = "#{object_id}: Asked for theme before theme was loaded."
        @log.error msg
        raise msg
      end

      return @theme
    end

    private

    # Loads data from the definition file -
    # these iclude also the nested LevelSuites or Levels

    def load_from_xml
      definition_file = @dirname + '/' + DEFINITION_FILE_NAME
      @log.debug "#{object_id}: Loading suite definition file #{definition_file}:"

      begin
        doc = REXML::Document.new(File.open(definition_file))
      rescue Errno::ENOENT
        @log.error "#{object_id}: Cannot load level suite definition file #{definition_file} - file not found."
        raise
      end

      @title = doc.root.elements['info'].elements['title'].text

      begin
        @theme_name = doc.root.elements['theme'].text
      rescue NoMethodError
        @log.debug "#{object_id}: LevelSuite #{@title} hasn't it's own graphic theme. (No 'theme' element found in definition file '#{definition_file}'.)"
      end

      # load theme:
      @theme = load_theme

      # load level suites:
      doc.root.elements['suite'].each_element('levelsuite') do |levelsuite_element|
        init_levelsuite levelsuite_element.text
      end

      # load levels:
      doc.root.elements['suite'].each_element('level') do |level_element|
        init_level level_element.text
      end

      @log.info "#{object_id}: Loaded LevelSuite #{@title}"
    end

    # Creates a LevelSuite object for a directory specified
    # in the definition file.
    # Argument dir is the base name of the directory.

    def init_levelsuite(dir)
      path = @dirname + '/' + dir

      begin
        @members.push LevelSuite.new(path, self)
      rescue LevelSuiteLoadException => ex
        @log.error "#{object_id}: Could not load LevelSuite from directory #{dir} (#{ex.class} occured)"
      end
    end

    # Creates a Level object for a directory specified
    # in the definition file.
    # Argument dir is the base name of the directory.

    def init_level(dir)
      path = @dirname + '/' + dir

      begin
        @members.push Level.new(path, self)
      rescue LevelSuiteLoadException => ex
        @log.error "#{object_id}: Could not load Level from directory #{dir} (#{ex.class} occured)"
      end
    end

    # loads GfxTheme; called from within load_from_xml before loading
    # nested levels

    def load_theme
      if @theme_name == "" then
        return (@member_of ? @member_of.gfx_theme : NullGfxTheme.instance)     
      end

      theme_def_file = FreeVikings::DEFAULT_THEME_DIR+'/'+@theme_name+'/'+THEME_FILE
      if File.exist? theme_def_file
        theme =  GfxTheme.new(theme_def_file, @member_of ? @member_of.gfx_theme : nil)
        @log.info "#{object_id}: Loaded theme '#{theme.name}' (file: #{theme_def_file}; ancestors: #{theme.ancestors.join(',')})."
        return theme
      else
        if @member_of
          @log.debug "#{object_id}: Theme file #{theme_def_file} wasn't found. Using inherited theme '#{@member_of.gfx_theme}'."
          return @member_of.gfx_theme
        else
          @log.debug "#{object_id}: Theme file #{theme_def_file} wasn't found. Levelsuite '#{@title}' has no own theme and doesn't inherit any. Using NullGfxTheme as theme."
          return NullGfxTheme.instance
        end
      end
    end

    def active_member
      @members[@active_member_i]
    end

    public

    # Raised by LevelSuite.new if some big problem occurs during the loading
    # phase.

    class LevelSuiteLoadException < RuntimeError
    end

    # Exception of this type is thrown when a password given 
    # to LevelSuite#level_with_password doesn't exist.

    class UnknownPasswordException < RuntimeError
    end # class UnknownPasswordException

  end # class LevelSuite
end # module FreeVikings



require 'level.rb'


# If this file is executed as a standalone script, loaded values are printed
# out (this was used for testing of LevelSuite class instead of unit tests)
if __FILE__ == $0 then
  c = FreeVikings::LevelSuite.new('locs/DefaultCampaign')

  puts "\n----- LevelSuite test output:"

  puts "\n--- Members of the default campaign levelsuite:\n"
  p c.members

  puts "\n--- Levels of the default campaign levelsuite:\n"
  p c.levels

  puts "\n--- Next level:\n"
  p c.next_level
end
