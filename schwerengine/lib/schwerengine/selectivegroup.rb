# selectivegroup.rb
# igneus 9.11.2005

=begin
= NAME
SelectiveGroup

= DESCRIPTION
(({SelectiveGroup})) is a (({Group})) which only accepts members which
realize some conditions.

= Superclass
Group
=end

module SchwerEngine

  class SelectiveGroup < Group

=begin
--- SelectiveGroup.(condition_proc)
((|condition_proc|)) must be a callable object ((({Proc})) instance usually)
which accepts one argument - an object being tested - and returns ((|true|))
or ((|false|)).
=end

    def initialize(condition_proc)
      super()
      @condition = condition_proc
    end

=begin
--- SelectiveGroup#acceptable?(object)
Says if ((|object|)) realizes the condition to be a member of the group.
=end

    def acceptable?(object)
      return @condition.call(object)
    end

    def add(object)
      unless acceptable?(object)
        raise ObjectNotAcceptable, "Object doesn't realize the condition."
      end

      super(object)
    end

=begin
--- SelectiveGroup::ObjectNotAcceptable
Exception raised by ((<SelectiveGroup#add>)) if the added object doesn't 
realize the condition.
=end

    class ObjectNotAcceptable < RuntimeError
    end
  end # class SelectiveGroup
end # module SchwerEngine
