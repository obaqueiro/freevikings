# monsterscript.rb
# igneus 19.6.2005

=begin
= MonsterScript
MonsterScript is a Script subclass specialized only on freeVikings
monster scripts. It loads all the monsters from the script and provides
an interface to get them.
=end

require 'script'

module FreeVikings

  class MonsterScript < Script

    def initialize(script_name)
      module_eval "MONSTERS = []"
      super script_name
    end

    def monsters
      if self::MONSTERS.empty?
	Log4r::Logger['freeVikings log'].info "In scriptfile #{scriptfile}: constant MONSTERS hasn't been defined. Maybe the script doesn't provide monsters."
      end
      return self::MONSTERS
    end
  end
end # module FreeVikings
