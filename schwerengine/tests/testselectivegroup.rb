# testselectivegroup.rb
# igneus 9.11.2005

class TestSelectiveGroup < TestGroup

  module FlagMixin
  end

  def setup
    @group = SelectiveGroup.new(Proc.new {|o|
                                  o.kind_of? FlagMixin
                                })

    @object = Sprite.new [90,90,12,12]
    @object.extend FlagMixin
  end

  undef_method :testMembersOnRectFindsMoreMembers
  undef_method :testMembersOnRectDoesNotFindNotCollidingMembers

end
