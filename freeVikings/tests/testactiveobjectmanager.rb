# testactiveobjectmanager.rb
# igneus 19.6.2005

require 'testgroup.rb'

require 'activeobjectmanager.rb'
require 'activeobject.rb'

class TestActiveObjectManager < TestGroup

  def setup
    @group = ActiveObjectManager.new
    @object = ActiveObject.new [90,90,12,12]
  end
end
