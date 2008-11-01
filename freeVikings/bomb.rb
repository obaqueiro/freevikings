# bomb.rb
# igneus 31.10.2008

module FreeVikings

  # Bomb is a very nice and safe item. However, once it is used,
  # it becomes explosive and destroys monsters, vikings and even some
  # other objects (like some walls).

  class Bomb < Item

    def apply(user)
      user.location << BombSprite.new(user.rect.center)
    end

    def init_images
      @image = Image.load 'bomb1.tga'
    end

    # Actually, BombSprite (which is a highly destructive Sprite) is 
    # what makes fun. Not Bomb (which is an Item) itself.

    class BombSprite < Sprite

      VELOCITY = 30

      WIDTH = HEIGHT = 30

      def initialize(pos, seconds_to_explosion=4)
        super(pos)
        @seconds_to_explosion = seconds_to_explosion
        @explosion_forced = false
      end

      # Flag (Boolean). Says other BombSprites:
      # don't force me to explode, I'm gonna explode in a short time
      # because someone has forced me before you!

      attr_reader :explosion_forced

      def update
        fall or start_timer or explode
      end

      # Following three methods are called from update one after another
      # in a special manner:
      # Every of them returns false if it has already done it's task,
      # otherwise it returns true

      def fall
        if @fallen then
          return false
        end

        if @location.area_free?(next_position) then
          @rect = next_position
          return true
        else
          @fallen = true
          return false
        end
      end

      def start_timer
        if ! defined?(@explosion_timer) then
          @explosion_timer = TimeLock.new @seconds_to_explosion
          return true
        end

        return false
      end

      def explode
        unless @explosion_timer.free? then
          return true
        end

        flame_rect = @rect.expand(90, 40)

        @location.sprites_on_rect(flame_rect).each {|s|
          if s == self then
            next
          end

          if s.class == BombSprite && s.explosion_forced == false then
            s.force_explosion
            next
          end

          if s.is_a?(Hero) or s.is_a?(Monster) then
            s.destroy
            next
          end
        }

        # fire on bombs
        @location.items_on_rect(flame_rect).each {|i|
          if i.class == Bomb then
            @location.delete_item i
            b = BombSprite.new(i.rect)
            @location << b
            b.force_explosion
          end
        }

        # destroy walls
        @location.static_objects_on_rect(flame_rect).each {|o|
          if o.class == Wall then
            o.bash
          end
        }

        @location.delete_sprite self

        return false
      end

      # Forces bomb to explode nearly immediately

      def force_explosion
        if (! defined?(@explosion_timer)) || 
            @explosion_timer.time_left > 0.5 then
          @explosion_timer = TimeLock.new 0.5
        end
      end

      def init_images
        @image = Animation.new(0.4, [Image.load('bomb1.tga'),
                                     Image.load('bomb2.tga'),
                                     Image.load('bomb3.tga')], 'Bomb')
      end

      private

      def next_position
        n = @rect.dup
        n.top += @location.ticker.delta * VELOCITY
        return n
      end
    end
  end
end
