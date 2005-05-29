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

    def d_on
    end

    def d_off
    end

=begin
--- Ability#to_s
This method doesn't behave as to_s methods usually do (e.g. in Ruby's 
stdlib classes' instances). It returns a String if the Ability is active
and nil otherwise. It is because of the usage of Ability objects in
VikingState. See VikingState documentation for more details.
=end

    def to_s
      @active_ability
    end
  end # class Ability

  class WariorAbility < Ability

    D_ABILITY = 'bow-stretching'

    def initialize(owner)
      super owner
    end

    def d_on
      @owner.stop
      @active_ability = D_ABILITY
    end

    def d_off
      if @active_ability == D_ABILITY
        @owner.shoot
        @active_ability = NO_ABILITY
      end
    end
  end # class WariorAbility
end # module FreeVikings
