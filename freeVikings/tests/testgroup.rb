# testgroup.rb
# igneus 19.6.2005

# Nedavno jsem prvne pracoval s Rubygame (je to jeden ze tri portu SDL do Ruby,
# napodobuje pythonovsky modul Pygame, ale ma pochopitelnejsi a pruhlednejsi
# zachazeni se skupinami sprajtu) a uvedomil jsem si, ze vsichni moji
# "manageri" (SpriteManager, ItemManager, ActiveObjectManager, ...) jsou
# duplicitni zarizeni, ktera by mela mit spolecneho predka (v Rubygame by to
# byla trida SpriteGroupClass, jenze ja mam rad RUDL a nechci freeVikings
# prenaset na Rubygame). Tak tady jsou testy pro tu zadanou supertridu.

require 'test/unit'

require 'group.rb'

class TestGroup < Test::Unit::TestCase

  include FreeVikings

  def setup
    @group = Group.new
    @object = Object.new
  end

  def testAddInclude
    @group.add @object
    assert @group.include?(@object), "Group should know about the included object.]"
  end

  def testDelete
    @group.add @object
    @group.delete @object
    assert_equal false, @group.include?(@object), "Group mustn't contain a deleted object."
  end
end
