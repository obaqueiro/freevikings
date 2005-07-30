# staticobject.rb
# igneus 31.7.2005

=begin
= StaticObject
((<StaticObject>)) is a mixin module to be mixed into static objects
(to learn more about static objects read documentation for class (({Map}))).
=end

module FreeVikings

  module StaticObject

=begin
--- StaticObject#solid
--- StaticObject#solid?
Tells if the object is solid or not.
=end

    def solid
      false
    end

    alias_method :solid?, :solid

=begin
--- StaticObject#image
=end

    def image
      @image.image
    end
  end # module StaticObject
end # module FreeVikings
