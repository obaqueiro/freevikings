# arrowshooter.rb
# igneus 10.10.2005

=begin
= NAME
ArrowShooter

= DESCRIPTION
A (({Shooter})) which shoots an (({Arrow})) whenever a (({Hero})) occurs
in the watched (({Rect})).
(The (({Arrow})) is modified to kill (({Hero}))es, of course.)

= Superclass
Shooter
=end

require 'monsters/shooter.rb'

module FreeVikings

  class ArrowShooter < Shooter

    WIDTH = HEIGHT = 40
    SHOT_VELOCITY = - 85
    SHOT_DELAY = 1.5

    def initialize(position)
      super(position)
      @watched_rect = Rectangle.new(@rect.left-100, @rect.top - 20,
                                    @rect.w + 100, @rect.h + 2*20)
      @delayer = TimeLock.new SHOT_DELAY
    end

=begin
= Instance methods

--- ArrowShooter#on
Switches the (({ArrowShooter})) on.
=end

    def on
      @firing = true
    end

=begin
--- ArrowShooter#off
Switches the (({ArrowShooter})) off.
=end

    def off
      @firing = false
    end

=begin
--- ArrowShooter#state
It's an alias of superclasse's (({firing?})).
It's defined to support (({Model})).
=end

    alias_method :state, :firing?

    def update
      @location.sprites_on_rect(@watched_rect).each do |sprite|
        if sprite.kind_of? Hero then
          shoot
        end
      end
    end

    def init_images
      @image = Model.new(self)
      @image.add_pair 'true', Image.load('arrowshooter_on.tga')
      @image.add_pair 'false', Image.load('arrowshooter_off.tga')
    end

    private

    def shoot
      return unless @delayer.free?

      if @firing then
        shot = Arrow.new([@rect.left - 20, @rect.top + 15], SHOT_VELOCITY)
        shot.hunted_type = Hero
        @location.add_sprite(shot)

        @delayer = TimeLock.new SHOT_DELAY, @location.ticker
      end
    end
  end # class ArrowShooter
end # module FreeVikings
