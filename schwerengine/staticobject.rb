# staticobject.rb
# igneus 31.7.2005

=begin
= StaticObject
((<StaticObject>)) is a mixin module to be mixed into static objects
(to learn more about static objects read documentation for class (({Map}))).
=end

module SchwerEngine

  module StaticObject

=begin
--- StaticObject#solid?
Tells if the object is solid or not. (((|false|)) by default.)
=end

    def solid?
      false
    end

    def register_in(location)
      location.add_static_object self
    end
  end # module StaticObject
end # module SchwerEngine
