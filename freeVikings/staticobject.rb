# staticobject.rb
# igneus 31.7.2005

module FreeVikings

  # StaticObject is a mixin module to be mixed into static objects
  # (to learn more about static objects read documentation for class Map).

  module StaticObject

    # Tells if the object is solid or not. false by default.)

    def solid?
      false
    end

    # Tells if the object is semisolid (i.e. it is possible to stand on it,
    # but also to go or jump through it)

    def semisolid?
      false
    end

    def at_least_semisolid?
      solid? || semisolid?
    end

    def solidness
      if solid? then
        return 'solid'
      elsif semisolid? then
        return 'semisolid'
      else
        return 'free'
      end
    end

    def register_in(location)
      location.add_static_object self
    end

    def unregister_in(location)
      location.delete_static_object self
    end
  end # module StaticObject
end # module FreeVikings
