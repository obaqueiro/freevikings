# levelsuite.rb
# igneus 1.8.2005

=begin
= LevelSuite
((<LevelSuite>)) is a set of (({LevelSuite}))s.
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
--- LevelSuite.new(dir)
Argument ((|dir|)) is of type (({Dir})). It is a name of the directory where
the file (('campaign.xml')) for the loaded campaign is.
=end

    def initialize(dirname)
      @dirname = dirname
      @members = []
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
The (({Level})) objects aren't stored in the ((<LevelSuite>)) instance,
but are obtained by call to (({LevelSuite#next_level})).
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

    private

    # Loads data from the definition file

    def load_from_xml
      definition_file = @dirname + '/' + DEFINITION_FILE_NAME
      doc = REXML::Document.new(File.open(definition_file))

      # load level suites:
      doc.root.elements['suite'].each_element('levelsuite') do |levelsuite_element|
        init_levelsuite levelsuite_element.text
      end

      # load levels:
      doc.root.elements['suite'].each_element('level') do |level_element|
        init_level level_element.text
      end
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
      @members.push Level.new(path)
    end

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
