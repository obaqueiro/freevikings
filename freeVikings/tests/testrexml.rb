# testrexml.rb
# igneus 6.3.2004

# Testy pro zjisteni, jak co v REXML funguje (hlavne vyhazovani vyjimek).
# Podle terminologie Kenta Becka tkzv. vyukove testy.

require 'rubyunit'
require 'rexml/document'

$xmltext = <<-EOS
<main>
</main>
EOS

$invalidxmltext = <<-EOS
<main> <first> <second> </first> </second> </main>
EOS

class TestExploreREXML < RUNIT::TestCase

  def setup
    @doc = REXML::Document.new($xmltext)
  end

  def testInvalidDocument
    # Pokud dokument neni platny, REXML pri jeho parsovani nemuze
    # najit tridu REXML::Validation. Pokud tedy mame stare REXML. Tehdy
    # nastane NameError.
    # Nove REXML vyhazuje vlastni vyjimku.
    assert_exception (REXML::ParseException) {
      d = REXML::Document.new $invalidxmltext
    }
  end

end
