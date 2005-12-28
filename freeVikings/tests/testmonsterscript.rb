# testmonsterscript.rb
# igneus 19.6.2005

# Sada testu pro MonsterScript.
# Testy se tykaji prevazne bezproblemoveho osetreni vyjimek.

require 'test/unit'
require 'tempfile'

require 'locationscript.rb'

class TestMonsterScript < Test::Unit::TestCase

  def setup
    @tmpscript = Tempfile.open("testscript")
  end

  def teardown
    @tmpscript.close!
  end

  def testScriptWithSyntaxError
    @tmpscript.puts SCRIPT_WITH_SYNTAX_ERROR
    @tmpscript.flush

    assert_raise(SyntaxError, "There is a syntax error in the script.") do
      FreeVikings::LocationScript.new @tmpscript.path
    end
  end

  def testScriptWithUndefinedConstant
    @tmpscript.puts SCRIPT_WITH_UNDEFINED_CONSTANT
    @tmpscript.flush

    assert_raise(NameError, "An uninitialized constant is used in the script.") do
      FreeVikings::LocationScript.new @tmpscript.path
    end
  end

  SCRIPT_WITH_SYNTAX_ERROR = "MONSTERS :===: 12"
  SCRIPT_WITH_UNDEFINED_CONSTANT = "puts MKHlkGRJfg"
  SCRIPT_WITHOUT_MONSTERS = "i = 5 + 3"

end
