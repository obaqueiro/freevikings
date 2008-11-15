# bomb.rb
# igneus 31.10.2008

module FreeVikings

  # Bomb is a very nice and safe item. However, once it is used
  # by a viking (or touched by flame of exploding bomb), it is replaced
  # with instance of Bomb::BombSprite, which looks nearly the same like
  # Bomb, but is animated and explodes after some time, killing Monsters,
  # Heroes, destroying walls and initiating other bombs.

  class Bomb < Item

    def apply(user)
      user.location << BombSprite.new(user.rect.center)
    end

    def init_images
      @image = Image.load 'bomb1.tga'
    end

    # See what has been said in documentation of class Bomb.
    #
    # When exploding, BombSprite makes use of another internal object -
    # Bomb::BombSprite::Flame, which makes animated flame effect and does
    # the actual work of destruction.

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

        # place flame in the location; Flame does all the destructive work
        @location << Flame.new(@rect.center)

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

      public

      # When Bomb::BombSprite explodes, places Bomb::BombSprite::Flame
      # into the Location; Flame makes an animated flame effect and kills
      # Monsters, Heroes, destroys destroyable walls and initiates
      # Bombs. It also forces BombSprites to explode sooner.

      class Flame < Sprite

        WIDTH = 180
        HEIGHT = 80

        # position isn't handled as a position of top-left corner,
        # but as a position of center!
        def initialize(position)
          super([position[0]-WIDTH/2, position[1]-HEIGHT/2])
          @flame_img = Image.load 'flame_bit.tga'

          @display_lock = TimeLock.new(1)

          @explosion_time = Time.now.to_f

          @state = EXPAND
          @animation_counter = 0
        end

        # internal state codes
        EXPAND, KILL, DISMISS, DONE = 1,2,3,4
        # time of expand/dismiss animation (in seconds)
        ANIMATION_TIME = 1
        ANIMATION_FRAMES = 10
        FRAME_TIME = ANIMATION_TIME / ANIMATION_FRAMES

        def location=(l)
          super(l)

          unless @location.area_free?(@rect) then
            # In future @rect should be shrinked here so that flame
            # can't reach behind solid tiles, shield etc.
          end

          s = RUDL::Surface.new [@rect.w, @rect.h]
          red = [255,0,0]
          s.fill red
          s.set_colorkey red      
          @image = Image.wrap s
        end

        def update
          time = Time.now.to_f
          time_since_expl = (time - @explosion_time)

          case @state
          when EXPAND
            while (time_since_expl / FRAME_TIME) > @animation_counter do
              @animation_counter += 1

              if @animation_counter > ANIMATION_FRAMES then
                @state = KILL
                break
              end

              offset_x = (@rect.w / 2) - ((@rect.w / 2) / ANIMATION_FRAMES) * @animation_counter
              offset_y = (@rect.h / 2) - ((@rect.h / 2) / ANIMATION_FRAMES) * @animation_counter
              # vertical part of flame
              x = (@rect.w / 2) - (@flame_img.w / 2)
              [offset_y, @rect.h - (offset_y + @flame_img.h)].each {|y|
                @image.image.blit(@flame_img.image, [x,y])
              }

              # horizontal part of flame
              y = (@rect.h / 2) - (@flame_img.h / 2)
              [offset_x, @rect.w - (offset_x + @flame_img.w)].each {|x|
                @image.image.blit(@flame_img.image, [x,y])
              }
            end
          when KILL
            do_destruction
            @state = DISMISS
          when DISMISS
            @location.delete_sprite self
            @state = DONE
          end
        end

        private

        # Does all the destructive work

        def do_destruction
          @location.sprites_on_rect(@rect).each {|s|
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
          @location.items_on_rect(@rect).each {|i|
            if i.class == Bomb then
              @location.delete_item i
              b = BombSprite.new(i.rect)
              @location << b
              b.force_explosion
            end
          }

          # destroy walls
          @location.static_objects_on_rect(@rect).each {|o|
            if o.class == Wall then
              o.bash
            end
          }
        end
      end # class Bomb::BombSprite::Flame
    end # class Bomb::BombSprite
  end # class Bomb
end # module FreeVikings
