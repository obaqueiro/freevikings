# testrexml.rb
# igneus 6.3.2004

# Testy pro zjisteni, jak co v REXML funguje (hlavne vyhazovani vyjimek).
# Podle terminologie Kenta Becka tkzv. vyukove testy.

require 'rubyunit'
require 'rexml/document'

class TestExploreREXML < RUNIT::TestCase

  PYRAMIS_LOC_XML_FILE = '../locs/DefaultCampaign/EgyptLevelSet/SlugHouse/pyramida_loc.xml'

@@xmltext = <<-EOS
<main>
<anything>
<goodBye />
</anything>
</main>
EOS

@@invalidxmltext = <<-EOS
<main> <first> <second> </first> </second> </main>
EOS

  def setup
    @doc = REXML::Document.new(@@xmltext)
  end

  def testInvalidDocument
    # Pokud dokument neni platny, REXML pri jeho parsovani nemuze
    # najit tridu REXML::Validation. Pokud tedy mame stare REXML. Tehdy
    # nastane NameError.
    # Nove REXML vyhazuje vlastni vyjimku.
    assert_exception (REXML::ParseException) {
      d = REXML::Document.new @@invalidxmltext
    }
  end

  def testValidStringDocumentRootIsNotNil
    d = REXML::Document.new @@xmltext
    assert_not_nil d.root, 'Document initialised by the valid XML String has to have non-nil root attribute'
  end

  def testValidFileDocumentRootIsNotNil
    fr = File.open(PYRAMIS_LOC_XML_FILE)
    d = REXML::Document.new(fr)
    assert_not_nil d.root, 'Document initialised by the valid XML file name has to have non-nil root attribute'
  end

end
