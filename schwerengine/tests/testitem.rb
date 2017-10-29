# testitem.rb
# igneus 21.6.2005

# Item is an Entity which can be collected and then used, but nothing more.

require 'testentity.rb'

class TestItem < TestEntity

  def setup
    @entity = @item = Item.new(STARTPOS)
  end

  def testApplyMethod
    assert_respond_to @item, :apply, "Method 'apply' is the only method important for the Items."
  end
end
