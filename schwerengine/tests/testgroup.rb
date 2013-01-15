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

  include SchwerEngine

  def setup
    @group = Group.new
    @object = Sprite.new [90,90,12,12]
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

  def testMembersOnRect
    @group.add @object
    assert_equal @object, @group.members_on_rect(Rectangle.new(85,85,60,60))[0], "There must be one sprite. I made it to be there."
  end

  def testMembersOnRectFindsMoreMembers
    @group.add @object
    @group.add Sprite.new([82,82])
    @group.add Sprite.new([140,140])
    assert_equal 3, @group.members_on_rect(Rectangle.new(80,80,60,60)).size, "There are two members colliding with the specified rectangle."
  end

  def testMembersOnRectDoesNotFindNotCollidingMembers
    @group.add Sprite.new([120,120])
assert_equal 0, @group.members_on_rect(Rectangle.new(10,10,10,10)).size, "The only sprite added does not collide with the specified rectangle."
  end

end
