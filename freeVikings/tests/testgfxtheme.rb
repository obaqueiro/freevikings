# testgfxtheme.rb
# igneus 3.8.2005

# Tests for GfxTheme class.
# GfxTheme class should solve the problem of different images for one
# Entity in different levelsets.

require 'test/unit'

require 'gfxtheme.rb'
require 'model.rb'

require 'stringio'

class TestGfxTheme < Test::Unit::TestCase

  include FreeVikings

  def setup
    @doc = StringIO.new("<gfx_theme><info><name>Test Theme</name><directory>themes/IceTheme</directory></info><data><image name=\"armour\" image=\"ice_apex.tga\"/></data></gfx_theme>")
    @doc2 = StringIO.new("<gfx_theme><info><name>Test Theme2</name><directory>themes/IceTheme</directory></info><data><image name=\"leviathan\" image=\"ice_apex.tga\"/></data></gfx_theme>")
    @theme = GfxTheme.new(@doc)
  end

  def testHasImageForDefinedName
    assert_kind_of FreeVikings::Image, @theme['armour'], "Name 'armour' has been defined in the configuration file. The image should have been loaded."
  end

  def testExceptionOnUndefinedName
    assert_raise(GfxTheme::UnknownNameException, "When the GfxTheme is indexed by an undefined name, an exception must be thrown.") do
      @theme["o-zone"]
    end
  end

  def testSearchInParent
    parent = {'leviathan' => 'image of leviathan'}
    @doc.rewind
    t = GfxTheme.new(@doc, parent)
    assert_equal 'image of leviathan', t['leviathan'], "GfxTheme must try to find the image in the parent theme."
  end

  def testKnownNames
    assert_equal ['armour'], @theme.known_names, "This theme knows only one image named 'armour'."
  end

  def testKnownNamesFromParent
    parent = GfxTheme.new @doc2
    @doc.rewind
    t = GfxTheme.new(@doc, parent)
    assert_equal ['armour', 'leviathan'], t.known_names, "Theme knows names 'armour' and 'leviathan'. 'leviathan' has been inherited."
  end

  def testDefaultGfxDir
    doc_without_dir = StringIO.new("<gfx_theme><info><name>Dirless Theme</name></info><data></data>")
    t = GfxTheme.new(doc_without_dir)
    assert_equal GFX_DIR, t.gfx_directory, "'#{GFX_DIR}' is the default graphics directory. It must be set, when the 'directory' element is not accessible."
  end

  def testDefaultName
    doc_without_name = StringIO.new("<gfx_theme><info></info><data></data>")
    t = GfxTheme.new(doc_without_name)
    assert_equal "Nameless theme", t.name, "Element 'name' is not in the XML file, so a default name must be used."
  end
end
