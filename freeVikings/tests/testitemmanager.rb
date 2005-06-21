# testitemmanager.rb
# igneus 21.6.2005

# Tests for ItemManager - a Group of Items

require 'testgroup.rb'

require 'itemmanager.rb'

class TestItemManager < TestGroup

  def setup
    @group = ItemManager.new
    @object = Item.new [90,90,12,12]
  end
end
