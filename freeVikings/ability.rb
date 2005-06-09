# ability.rb
# igneus 29.5.2005

module FreeVikings

=begin
= Ability
Ability is an object which works around all the abilities specific
for each viking. E.g. Baleog's ability object makes it possible
to use the sword and throw arrows.

Instances of class Ability can be used as "Null Objects", they don't do
anything. All the specifics are in Ability's subclasses.

== Ability activating/unactivating methods
--- Ability#d_on
--- Ability#d_off
--- Ability#space_on
--- Ability#space_off
Activating and unactivating of vikings' abilities is traditionally
connected with keys d, f and space. Methods controlling
the abilities are called after the keys.
=end

  class Ability

    NO_ABILITY = nil

=begin
--- Ability.new(owner)
One argument - owner of the ability (usually a viking) - is accepted.
=end

    def initialize(owner=nil)
      @owner = owner
      @active_ability = nil
    end

    attr_reader :active_ability

    def d_on
    end

    def d_off
    end

    def space_on
    end

    def space_off
    end

=begin
--- Ability#to_s
This method doesn't behave as to_s methods usually do (e.g. in Ruby's 
stdlib classes' instances). It returns a String if the Ability is active
and nil otherwise. It is because of the usage of Ability objects in
VikingState. See VikingState documentation for more details.
=end
    alias_method :to_s, :active_ability

  end # class Ability

  class WariorAbility < Ability

    D_ABILITY = 'bow-stretching'
    SPACE_ABILITY = 'sword-fighting'

    def initialize(owner)
      super owner
    end

    def d_on
      @owner.stop
      @active_ability = D_ABILITY
    end

    def d_off
      if @active_ability == D_ABILITY
        @owner.release_arrow
        @active_ability = NO_ABILITY
      end
    end

    def space_on
      @owner.stop
      @active_ability = SPACE_ABILITY
      @owner.draw_sword
    end

    def space_off
      if @active_ability == SPACE_ABILITY then
        @owner.hide_sword
        @active_ability = NO_ABILITY
      end
    end
  end # class WariorAbility

  class SprinterAbility < Ability

    SPACE_ABILITY = 'jumping'
    D_ABILITY = 'sprinting'

    def initialize(owner)
      super owner
    end

    def space_on
      unless @active_ability
        @active_ability = SPACE_ABILITY
        @owner.jump
      end
    end

    def space_off
      if @active_ability == SPACE_ABILITY
        @active_ability = nil
        @owner.state.descend
      end
    end
  end # class SprinterAbility

  class ShielderAbility < Ability

    SHIELD_TOP = true
    SHIELD_FRONT = false

    def initialize(owner)
      super owner
      @shield_use = SHIELD_FRONT
    end

    attr_reader :shield_use

    def space_on
      @shield_use = ! @shield_use
    end
  end # class ShielderAbility
end # module FreeVikings
