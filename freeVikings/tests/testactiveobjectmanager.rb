# testactiveobjectmanager.rb
# igneus 19.6.2005

require 'testgroup.rb'

require 'activeobjectmanager.rb'
require 'activeobject.rb'

class TestActiveObjectManager < TestGroup

  def setup
    @group = ActiveObjectManager.new
    @object = ActiveObject.new
  end
end
