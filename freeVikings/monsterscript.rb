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

    def initialize(script_name, dir='')
      module_eval "MONSTERS = []"

      if File.exist?(dir + '/' + script_name)
        super dir+'/'+script_name
      else
        super script_name
      end

      if self::MONSTERS.empty? and not defined?(self::LOCATION) then
        raise NoMonstersDefinedException, "No monsters have been defined in the script."
      end
    end

    def monsters
      return self::MONSTERS
    end

    # This exception is raised when the script is all right, but does not
    # define any monsters. (It should always define some - it's a monster
    # script!)
    class NoMonstersDefinedException < RuntimeError
    end
  end # class MonsterScript
end # module FreeVikings
