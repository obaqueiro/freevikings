# runestone.rb
# igneus 15.12.2008

module FreeVikings

  # Stone with a rune on it. May be used as decoration.

  class RuneStone < Entity

    WIDTH = 60
    HEIGHT = 80

    include StaticObject

    RUNES_ARRAY = [
      ['f', 'fe'],
      ['u', 'ur'],
      ['th', 'thurs'],
      ['o', 'oss'],
      ['r', 'raid'],
      ['k', 'kaun'],
      ['h', 'hagal'],
      ['n', 'naud'],
      ['i', 'is'],
      ['a', 'ar'],
      ['s', 'soi'],
      ['t', 'tyr'],
      ['b', 'bjarkan'],
      ['m', 'madr'],
      ['l', 'logr'],
      ['y', 'yr']
    ]

    RUNES_HASH = {}
    RUNES_ARRAY.each_with_index {|r,i|
      RUNES_HASH[r[0]] = i
      RUNES_HASH[r[1]] = i
    }

    def initialize(position, rune='f')
      @rune = rune.downcase
      unless RUNES_HASH.has_key?(@rune)
        raise ArgumentError, "Unknown rune '#{@rune}'"
      end
      @rune_i = RUNES_HASH[@rune]

      super(position)      
    end

    def init_images
      runes = Image.load 'runes_large.png'
      @image = Image.load 'runestone.png'
      @image.image.blit(runes.image, [20,21], [@rune_i*30,0,30,40])
    end
  end

  # Small stone with a rune on it. 

  class RuneGem < Item

    def initialize(position, rune='f')
      @rune = rune.downcase
      unless RUNES_HASH.has_key?(@rune)
        raise ArgumentError, "Unknown rune '#{@rune}'"
      end
      @rune_i = RUNES_HASH[@rune]

      super(position)
    end

    def init_images
      runes = Image.load 'runes_small.png'
      @image = Image.load 'runegem.png'
      @image.image.blit(runes.image, [0,0], [@rune_i*30,0,30,30])
    end
  end

  # RuneStone which produces RuneGems.
  # Inherits interface of StaticObject from RuneStone, but it's main role is
  # role of ActiveObject!

  class GemSourceRuneStone < RuneStone

    def register_in(loc)
      loc.add_active_object self
      @location = loc
    end

    def activate(who=nil)
      pos = [@rect.left+WIDTH/2-RuneGem::WIDTH/2, @rect.top+30]
      @location << RuneGem.new(pos, @rune)
    end

    def deactivate(who=nil)
    end
  end
end
