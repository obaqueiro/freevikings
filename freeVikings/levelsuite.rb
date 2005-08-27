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
Argument ((|dir|)) is of type (({Dir})). It is a name of the directory where
the file (('campaign.xml')) for the loaded campaign is.
If the (({LevelSuite})) is nested in some other (({LevelSuite})), it's
given a second argument ((|member_of|)), which is a link to a 'parent'
(({LevelSuite})).
=end

    def initialize(dirname, member_of=nil)
      @log = Log4r::Logger['world log']

      @dirname = dirname
      @members = []
      @member_of = member_of

      @log.debug "#{object_id}: New LevelSuite created from data in directory '#{@dirname}' as a nested suite in #{@member_of ? @member_of.object_id : @member_of.to_s}"

      load_from_xml
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
Returns a (({Level})) with password ((|password|)) or throws 
((<LevelSuite::UnknownPasswordException>)) if none
exists. For more information about passwords read documentation for class
(({StructuredWorld})).
=end

    def level_with_password(password)
      @log.debug "Asked for a level with password #{password}."
      @members.each do |member_levelsuite|
        level = member_levelsuite.level_with_password(password)
        if level
          @log.info "Found level with password #{password}."
          return level
        end
      end
     
      @log.error "Level with password #{password} wasn't found."
      raise UnknownPasswordException, "Password #{password} doesn't exist."
    end

=begin
--- LevelSuite#gfx_theme
Returns a (({GfxTheme})) for the set of levels. (If htere isn't such
(({GfxTheme})), a (({NullGfxTheme})) is returned, but (({NullGfxTheme}))
behaves in the same way as normal (({GfxTheme})), so you don't need to
worry about it.)
=end

    def gfx_theme
      theme = (load_theme or NullGfxTheme.instance)
      unless theme.kind_of? GfxTheme
        raise TypeError, "Theme of bad type #{theme.class}"
      end

      return theme
    end

    private

    # Loads data from the definition file

    def load_from_xml
puts @dirname
      definition_file = @dirname + '/' + DEFINITION_FILE_NAME
      @log.info "#{object_id}: Loading suite definition file #{definition_file}:"
      doc = REXML::Document.new(File.open(definition_file))

      @title = doc.root.elements['info'].elements['title'].text

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
      @members.push LevelSuite.new(path)
    end

    # Creates a Level object for a directory specified
    # in the definition file.
    # Argument dir is the base name of the directory.

    def init_level(dir)
      path = @dirname + '/' + dir
      @members.push Level.new(path, self)
    end

    def load_theme
      theme_def_file = @dirname + '/' + THEME_FILE
      if File.exist? theme_def_file
        return GfxTheme.new(theme_def_file, @member_of ? @member_of.gfx_theme : nil)
      else
        @log.info "#{object_id}: Theme file #{theme_def_file} wasn't found. Levelsuite '#{@title}' has no own theme. (But maybe it inherits some...)"

        if @member_of
          return @member_of.gfx_theme
        else
          return NullGfxTheme.instance
        end
      end
    end

    public

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


# Pokud je tento soubor spusten jako samostatny skript, vyzkousi se funkcnost
# prostym vypisem nactenych hodnot
if __FILE__ == $0 then
  c = FreeVikings::LevelSuite.new('locs/DefaultCampaign')

  puts "\n----- LevelSuite test output:"

  puts "\n--- Members of the default campaign levelsuite:\n"
  p c.members

  puts "\n--- Next level:\n"
  p c.next_level
end
