# activeobjectmanager.rb
# igneus 19.6.2005

=begin
= ActiveObjectManager
ActiveObjectManager is a ((<Group>)) of ((<ActiveObject>))s.
=end

require 'group.rb'

module FreeVikings

  class ActiveObjectManager < Group
    include PaintableGroup
  end # class ActiveObjectManager
end # module FreeVikings
