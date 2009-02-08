# ability.rb
# igneus 29.5.2005

module FreeVikings

  # Ability is an object which works around all the abilities specific
  # for each viking. E.g. Baleog's ability object makes it possible
  # to use the sword and throw arrows.
  #
  # Instances of class Ability can be used as "Null Objects", they don't do
  # anything. All the specifics are in Ability's subclasses.
  
  class Ability

    NO_ABILITY = nil

    # One argument - owner of the ability (usually a viking) - is accepted.

    def initialize(owner=nil)
      @owner = owner
      @active_ability = nil
    end

    attr_reader :active_ability

    # == Ability activating/unactivating methods
    # Activating and unactivating of vikings' abilities is traditionally
    # connected with keys d, f and space. Methods controlling
    # the abilities are called after the keys.

    def d_on
    end

    def d_off
    end

    def space_on
    end

    def space_off
    end

    # This method doesn't behave as to_s methods usually do (e.g. in Ruby's 
    # stdlib classes' instances). It returns a String if the Ability is active
    # and nil otherwise. It is because of the usage of Ability objects in
    # VikingState. See VikingState documentation for more details.
    alias_method :to_s, :active_ability

  end # class Ability
end # module FreeVikings
