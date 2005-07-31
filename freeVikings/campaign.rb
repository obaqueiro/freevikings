# campaign.rb
# igneus 2.8.2005

=begin
= Campaign
((<Campaign>)) is a set of (({LevelSet}))s.
=end

require 'rexml/document'

require 'levelset.rb'

module FreeVikings

  class Campaign

=begin
--- Campaign::DEFINITION_FILE_NAME
Standard name of the XML file which contains the campaign's definition.
=end

    DEFINITION_FILE_NAME = 'campaign.xml'

=begin
--- Campaign.new(dir)
Argument ((|dir|)) is of type (({Dir})). It is a name of the directory where
the file (('campaign.xml')) for the loaded campaign is.
=end

    def initialize(dirname)
      @dirname = dirname
      load_from_xml
      init_levelsets
    end

=begin
--- Campaign#dirname
Returns a (({String})) with the name (usually a subpath) 
of the ((<Campaign>))'s directory.
=end

    attr_reader :dirname

=begin
--- Campaign#levelset_dirs
Returns an (({Array})) of base names of the directories where the levelsets
are stored.
=end

    attr_reader :levelset_dirs

=begin
--- Campaign#levelsets
Returns an (({Array})) of (({LevelSet})) objects.
=end

    attr_reader :levelsets

=begin
--- Campaign#next_level
Returns next (({Level})) from the ((<Campaign>)) or ((|nil|)) if any more
(({Level}))s are available.
The (({Level})) objects aren't stored in the ((<Campaign>)) instance,
but are obtained by call to (({LevelSet#next_level})).
=end

    def next_level
      unless defined?(@active_levelset)
        @active_levelset = @levelsets.shift
      end

      begin
        if (level = @active_levelset.next_level).nil? then
          # The active levelset has no more levels.
          # Set another levelset active and try to get a level once more:
          @active_levelset = @levelsets.shift
          return next_level
        else
          return level
        end
      rescue NoMethodError
        # This error occurs here when we haven't any more levelsets,
        # @levelsets.shift returns nil and this over this nil 'next_level'
        # is called.
        return nil
      end
    end

    private

    # Nacte data z definicniho souboru campaign.xml

    def load_from_xml
      definition_file = @dirname + '/' + DEFINITION_FILE_NAME
      @doc = REXML::Document.new(File.open(definition_file))

      @levelset_dirs = []

      @doc.root.elements['levelsets'].each_element('levelset') do |levelset_element|
        @levelset_dirs.push levelset_element.text
      end
    end

    # Vytvori objekt LevelSet pro kazdy adresar specifikovany 
    # v souboru campaign.xml

    def init_levelsets
      @levelsets = []
      @levelset_dirs.each do |levelset_dir|
        path = @dirname + '/' + levelset_dir

        @levelsets.push LevelSet.new(path)
      end
    end

  end # class Campaign
end # module FreeVikings



# Pokud je tento soubor spusten jako samostatny skript, vyzkousi se funkcnost
# prostym vypisem nactenych hodnot
if __FILE__ == $0 then
  c = FreeVikings::Campaign.new('locs/DefaultCampaign')
  p c.levelset_dirs
  p c.levelsets
  p c.next_level
end
