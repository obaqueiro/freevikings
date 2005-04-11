# testxmllocloadstrategy.rb
# igneus 29.3.2005

# Sada testovych pripadu, jejimz primarnim ukolem je zajisteni, aby
# strategie nahravani map z xml souboru vyhazovala chyby, pokud bude nacitan
# neplatny datovy soubor

require 'test/unit'

require 'xmllocationloadstrategy.rb'


class TestXMLLocationLoadStrategy < Test::Unit::TestCase

  include FreeVikings

  @@invalid_syntax = <<-EOS
<location>
<info><map></info></mao>
</location>
EOS

  @@valid_syntax = '<location><info></info></location>'

  def testInvalidSyntax
    assert_raises(REXML::ParseException) {
      s = XMLLocationLoadStrategy.new(@@invalid_syntax, nil)
    }
  end

  def testFailsToParseStringWhenSourceControlOn
    assert_raises(InvalidDataSourceException) {
      s = XMLLocationLoadStrategy.new(@@valid_syntax, true)
    }
  end

  def testExceptionOnNotExistingFileLoading
    assert_raises(InvalidDataSourceException) {
      XMLLocationLoadStrategy.new('XXXXXXxxxxxxxXXXXXXXXXX.lblabla')
    }
  end

end
