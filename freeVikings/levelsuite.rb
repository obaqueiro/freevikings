# levelsuite.rb
# igneus 1.8.2005

=begin
= LevelSuite
((<LevelSuite>)) is a set of ((<LevelSuite>))s.
=end

require 'rexml/document'

# require 'level.rb' # this require command is at the end of the file because
# Level < LevelSuite

module FreeVikings

  class LevelSuite

=begin
--- LevelSuite::DEFINITION_FILE_NAME
Standard name of the XML file which contains the campaign's definition.
=end

    DEFINITION_FILE_NAME = 'levelsuite.xml'

=begin
--- LevelSuite::THEME_FILE
Standard name of the XML file which defines the graphics theme.
=end

    THEME_FILE = 'theme.xml'

=begin
--- LevelSuite.new(dir, member_of=nil)
Argument ((|dir|)) is of type (({String})). It is a name of the directory where
the file (('campaign.xml')) for the loaded campaign is.
If the (({LevelSuite})) is nested in some other (({LevelSuite})), it's
given a second argument ((|member_of|)), which is a 'parent' (({LevelSuite})).
=end

    def initialize(dirname, member_of=nil)
      @log = Log4r::Logger['world log']

      @log.debug "#{object_id}: Loading a new level suite from directory #{dirname}."

      @dirname = dirname
      @members = []
      @member_of = member_of

      # values are usually changed in method load_from_xml
      @title = ""
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

      # theme can't be loaded before load_from_xml is called, because
      # we need to have the theme name
      @theme = load_theme

      @log.debug "#{object_id}: New LevelSuite created from data in directory '#{@dirname}' as a nested suite in #{@member_of ? @member_of.object_id : @member_of.to_s}"
    end

=begin
--- LevelSuite.is_levelsuite_directory?(dirname)
Says if specified directory contains the LevelSuite definition file.
=end

    def LevelSuite.is_levelsuite_directory?(dirname)
      deffile = dirname+'/'+DEFINITION_FILE_NAME

      if File.exist?(deffile) then
        return true
      else
        return false
      end
    end

=begin
--- LevelSuite#dirname
Returns a (({String})) with the name (usually a subpath) 
of the ((<LevelSuite>))'s directory.
=end

    attr_reader :dirname

=begin
--- LevelSuite#members
Returns an (({Array})) of (({LevelSuite})) objects.
=end

    attr_reader :members

=begin
--- LevelSuite#next_level
Returns next (({Level})) from the ((<LevelSuite>)) or ((|nil|)) if any more
(({Level}))s are available.

(Implementation detail:
The (({Level})) objects aren't stored in the ((<LevelSuite>)) instance,
but are obtained by call to (({LevelSuite#next_level})).)
=end

    def next_level
      unless @active_member
        @active_member = @members.shift
      end

      # This case occurs when an empty levelset directory
      # with a content-less levelsuite.xml file exists.
      if @active_member.nil? then
        return nil
      end

      if (level = @active_member.next_level).nil? then
        # The active levelset has no more levels.
        # Set another levelset active and try to get a level once more:
        @active_member = @members.shift

        if @active_member.nil? then
          return nil
        else
          return next_level
        end
      else
        return level
      end
    end

=begin
--- LevelSuite#level_with_password(password)
Returns a (({Level})) with password ((|password|)) and sets it active 
or throws ((<LevelSuite::UnknownPasswordException>)) if no such level
exists. For more information about passwords read documentation for class
(({StructuredWorld})).
=end

    def level_with_password(password)
      @log.debug "Asked for a level with password #{password}."

      while (level = next_level) do
        return level if level.password == password
      end
     
      @log.error "Level with password #{password} wasn't found."
      raise UnknownPasswordException, "Password #{password} doesn't exist."
    end

=begin
--- LevelSuite#gfx_theme
Returns a (({GfxTheme})) for the set of levels. (If there isn't such
(({GfxTheme})), a (({NullGfxTheme})) is returned, but (({NullGfxTheme}))
behaves in the same way as normal (({GfxTheme})), so you don't need to
worry about it.)
=end

    def gfx_theme
      if @theme then
        return @theme
      else
        return @theme = (load_theme or NullGfxTheme.instance)
      end
    end

    private

    # Loads data from the definition file

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
        @log.debug "LevelSuite #{@title} hasn't graphic theme."
      end

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
        @members.push LevelSuite.new(path)
      rescue LevelSuiteLoadException => ex
        @log.error "Could not load LevelSuite from directory #{dir} (#{ex.class} occured)"
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
        @log.error "Could not load Level from directory #{dir} (#{ex.class} occured)"
      end
    end

    def load_theme
      if @theme_name == "" then
        return (@member_of ? @member_of.gfx_theme : NullGfxTheme.instance)        
      end

      theme_def_file = FreeVikings.theme_dir+'/'+@theme_name+'/'+THEME_FILE
      if File.exist? theme_def_file
        theme =  GfxTheme.new(theme_def_file, @member_of ? @member_of.gfx_theme : nil)
        @log.info "#{object_id}: Loaded theme '#{theme.name}' (#{theme_def_file})."
        return theme
      else
        if @member_of and not @member_of.gfx_theme.kind_of? NullGfxTheme
          @log.debug "#{object_id}: Using inherited theme '#{@member_of.gfx_theme}'."
          return @member_of.gfx_theme
        else
          @log.debug "#{object_id}: Theme file #{theme_def_file} wasn't found. Levelsuite '#{@title}' has no own theme and doesn't inherit any."
          return NullGfxTheme.instance
        end
      end
    end

    public

=begin
--- LevelSuite::LevelSuiteLoadException
Raised by ((<LevelSuite.new>)) if some big problem occurs during the loading
phase.
=end

    class LevelSuiteLoadException < RuntimeError
    end

=begin
--- LevelSuite::UnknownPasswordException
Exception of this type is thrown when a password given 
to ((<LevelSuite#level_with_password>)) doesn't exist.
=end

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

  puts "\n--- Next level:\n"
  p c.next_level
end
