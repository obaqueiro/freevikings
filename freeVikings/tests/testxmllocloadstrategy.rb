# testxmllocloadstrategy.rb
# igneus 29.3.2005

# Sada testovych pripadu, jejimz primarnim ukolem je zajisteni, aby
# strategie nahravani map z xml souboru vyhazovala chyby, pokud bude nacitan
# neplatny datovy soubor

require 'test/unit'

require 'xmllocationloadstrategy.rb'


class TestXMLLocationLoadStrategy < Test::Unit::TestCase

  @@invalid_syntax = <<-EOS
<location>
<info><map></info></mao>
</location>
EOS

  def testInvalidSyntax
    assert_raises(NameError) {
      s = XMLLocationLoadStrategy.new(@@invalid_syntax)
    }
  end

end
