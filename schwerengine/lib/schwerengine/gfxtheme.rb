# gfxtheme.rb
# igneus 3.8.2005

=begin
= GfxTheme
Some types of objects ((({Switch}))es, (({Apex}))es, etc.) live in
several different level-sets and I would like some of them to
look different in the different environments.
Class ((<GfxTheme>)) should solve this my problem.
=end

require 'rexml/document'
require 'singleton'

module SchwerEngine

  class GfxTheme

=begin
--- GfxTheme::DEFAULT_THEME_NAME
=end

    DEFAULT_THEME_NAME = 'Nameless theme'

=begin
--- GfxTheme.new(theme_file)
Argument ((|theme_file|)) can be a (({String})), then it is used as a file 
name, or anything other, then it's used as a XML data source object with
interface common for (({IO})) instances (a well-known example of those
is (({StringIO})), which is a part of Ruby's stdlib).
Voluntary second argument ((|parent|)) is a 'parent theme', a theme, where
the (({GfxTheme})) lookes for images which aren't defined in it's own
internals.

This constructor can throw a wide scale of exceptions from REXML or from
class (({Image})).
=end

    def initialize(theme_file, parent=nil)
      @log = Log4r::Logger['images log']

      if theme_file.kind_of? String then
        @source = File.open theme_file
      else
        @source = theme_file
      end

      @parent = parent

      @images = {}

      load_theme_file(@source)
    end

=begin
--- GfxTheme#gfx_directory
Returns the directory where the (({GfxTheme}))'s graphic files are stored.
=end

    attr_reader :gfx_directory

=begin
--- GfxTheme#name
Returns a (({String})) - a name of the theme. It's usually human readable and
corresponds with the name of some campaign or levelset.
=end

    attr_reader :name

=begin
--- GfxTheme#[](name)
Operator of indexing. Returns (({Image})) with name ((|name|)) or throws
((<GfxTheme::UnknownNameException>)).
=end

    def [](name)
      unless @images[name]
        if @parent and @parent[name] then
          return @parent[name]
        else
          # Image with name name cannot be found anywhere.
          # Raise an exception:
          raise UnknownNameException, "Nothing known about image with name '#{name}' in theme '#{self.name}'. (Known names: #{known_names.join(', ')})"
        end
      end

      return @images[name]
    end

=begin
--- GfxTheme#null?
This is a comfortable way to distinguish ((<GfxTheme>)) and ((<NullGfxTheme>)).
Returns ((|false|)) for ((<GfxTheme>)), ((|true|)) for ((<NullGfxTheme>)).
=end

    def null?
      false
    end

    # Returns Array of Strings - names of images known to the theme and it's 
    # ancestor-themes

    def known_names
      names = @images.keys
      names.concat @parent.known_names if @parent
      return names
    end

    # Returns an Array of Strings - names of ancestor themes

    def ancestors
      if @parent and (@parent.null? == false) then
        return @parent.ancestors + [@parent.name]
      else
        return []
      end
    end

    private

    # loads the data from XML file; is called from the constructor

    def load_theme_file(file)
      @log.debug "Loading new graphics theme from file #{file}:"

      doc = REXML::Document.new file

      @gfx_directory = read_gfx_directory(doc)

      @name = read_theme_name(doc)
      
      @log.debug "Loading theme images:"
      doc.root.elements['data'].each_element('image') do |image_element|
        img_name = image_element.attributes['name']
        image_file = image_element.attributes['image']

        unless img_name
          @log.error "Found element 'gfx_theme/data/image' without compulsory attribute 'name' in theme source #{source_name}. Image cannot be loaded."
          continue
        end
        unless image_file
          @log.error "Found element 'gfx_theme/data/image' without compulsory attribute 'image' in theme source #{source_name}. (Name is #{img_name}.) Image cannot be loaded."
          continue
        end

        full_file_name = SchwerEngine.config::GFX_DIR + '/' + @gfx_directory + '/' + image_file

        @log.debug " - #{img_name}: #{full_file_name}"

        @images[img_name] = Image.new(full_file_name)
      end
      @log.info "Loaded graphics theme #{self.name}"
    end

    # reads safely and returns text of element gfx_theme/info/directory
    # from REXML::Document doc
    # If the element isn't specified, a default value is returned.

    def read_gfx_directory(doc)
      begin
         return doc.root.elements['info'].elements['directory'].text
      rescue NoMethodError
        # element 'directory' missing (...elements['directory'] returns nil
        # and nil doesn't respond to 'text'):
        @log.error "Missing element gfx_theme/info/directory in the theme file #{source_name}. Setting default value: #{SchwerEngine.config::GFX_DIR}"
        return SchwerEngine.config::GFX_DIR # set default
      end
    end

    # works in the similar way as read_gfx_directory, but reads contents
    # of the element gfx_theme/info/name.
    # If the element isn't specified, a default value is returned.

    def read_theme_name(doc)
      begin
        return doc.root.elements['info'].elements['name'].text
      rescue NoMethodError
        @log.error "Missing element gfx_theme/info/name in the theme file #{source_name}. Setting default value: #{DEFAULT_THEME_NAME}"
        return DEFAULT_THEME_NAME
      end
    end

    # If @source is a file, it's name is returned, otherwise the method
    # returns @source.to_s

    def source_name
      @source.kind_of?(File) ? @source.name : @source.to_s
    end

    public

    class UnknownNameException < RuntimeError
    end # class UnknownNameException
  end # class GfxTheme


=begin
= NullGfxTheme
(({NullGfxTheme})) is a subclass of (({GfxTheme})). It behaves totally 
the same, but doesn't contain any data and the contructor isn't available -
call ((<NullGfxTheme.instance>)) instead.
=end

  class NullGfxTheme < GfxTheme

    include Singleton

=begin
--- NullGfxTheme.instance
(({NullGfxTheme})) class mixes in the (({Singleton})) module, so it's
constructor is hidden and this method returns the only instance.
=end

    def initialize
      @parent = nil
      @images = {}      
      @name = "NullTheme"
    end

    def null?
      true
    end

    def ancestors
      []
    end
  end # class NullGfxTheme

end # module SchwerEngine
