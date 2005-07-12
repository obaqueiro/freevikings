# viking.rb
# igneus 20.1.2004

require 'log4r'

require 'sprite.rb'
require 'deadviking.rb'

require 'vikingstate.rb'
require 'imagebank.rb'
require 'nullocation.rb'
require 'collisiontest.rb'
require 'inventory.rb'
require 'map.rb' # kvuli const. TILE_SIZE
require 'sophisticatedspritemixins.rb'

=begin
= Viking
=end

module FreeVikings

  class Viking < Sprite

    include SophisticatedSpriteMixins::Walking

=begin
--- Viking::BASE_VELOCITY
Viking's default velocity in pixels per second.
=end

    BASE_VELOCITY = 65

=begin
--- Viking::WIDTH
--- Viking::HEIGHT
Sizes of the vikings' graphics.
=end

    WIDTH = 80
    HEIGHT = 100

=begin
--- Viking::MAX_ENERGY
Initial number of energy points. The viking should never have more then 
on the beginninig.
=end

    MAX_ENERGY = 3

=begin
--- Viking.new(name, start_position=[0,0])
Creates a new viking. Parameter ((|name|)) is a (({String})),
((|start_position|)) should be an (({Array})) or a (({Rectangle})).
=end

    def initialize(name, start_position=[0,0])
      super()
      @log = Log4r::Logger['viking log']
      @name = name
      @state = VikingState.new
      @log.debug("Viking #{@name} initialised.")
      @rect = Rectangle.new start_position[0], start_position[1], WIDTH, HEIGHT
      @energy = MAX_ENERGY # zivotni sila

      @portrait = nil

      @inventory = Inventory.new
    end

=begin
--- Viking.createWarior(name, start_position)
--- Viking.createSprinter(name, start_position)
--- Viking.createShielder(name, start_position)
Factory methods which create subclasses' instances.
=end

    def Viking.createWarior(name, start_position)
      return Warior.new(name, start_position)
    end

    def Viking.createSprinter(name, start_position)
      return Sprinter.new(name, start_position)
    end

    def Viking.createShielder(name, start_position)
      return Shielder.new(name, start_position)
    end

=begin
--- Viking#name => aString
Returns ((<Viking>))'s name.
=end

    attr_reader :name

=begin
--- Viking#state => aVikingState
Returns ((<Viking>))'s state. To learn more about it, study documentation 
for class (({VikingState})).
=end

    attr_reader :state

=begin
--- Viking#energy => aFixnum
Returns ((<Viking>))'s energy as a number which shouldn't ever overgrow
((<Viking::MAX_ENERGY>)) and descend under zero.
=end

    attr_reader :energy

=begin
--- Viking#portrait => aPortrait
Returns a (({Portrait})) of the ((<Viking>)).
=end

    attr_reader :portrait

=begin
--- Viking#inventory => anInventory
((<Viking>))'s (({Inventory})).
=end

    attr_reader :inventory

=begin
--- Viking#hurt => anInteger
Takes the ((<Viking>)) off one energy point.
If the energy falls onto zero, ((<Viking#destroy>)) is called.
Returns his energy after the injury.
=end

    def hurt
      @energy -= 1
      destroy if @energy <= 0
      return @energy
    end

=begin
--- Viking#heal => aBoolean
If the ((<Viking>)) doesn't have full energy (see ((<Viking::MAX_ENERGY>))), 
adds him one energy point and returns ((|true|)).
Otherwise ((|false|)) is returned and nothing added.
=end

    def heal
      if @energy < MAX_ENERGY
        @energy += 1
        return true
      else
        return false
      end
    end

=begin
--- Viking#destroy => aViking
Sets energy to zero, deletes the ((<Viking>)) from the (({Location})) and
adds a new (({Sprite})) representing a corpse into it.
This method is called when the ((<Viking>)) is killed directly 
without any discussion (e.g. when a skyscraper falls onto his uncovered head) 
or when his energy falls onto zero (see ((<Viking#hurt>))).
Returns the ((<Viking>)) itself.
=end

    def destroy
      @energy = 0
      @location.add_sprite DeadViking.new([left, top])
      @location.delete_sprite self
      self
    end

=begin
--- Viking#space_func_on
--- Viking#space_func_off
Switch on/off ((<Viking>))'s first special ability.
=end

    def space_func_on
    end

    def space_func_off
    end

=begin
--- Viking#d_func_on
--- Viking#d_func_off
Switch on/off ((<Viking>))'s second special ability.
=end

    def d_func_on
    end

    def d_func_off
    end

=begin
--- Viking#use_item => aBoolean
Tries to use the active (({Item})) from the ((<Viking>))'s (({Inventory})).
If it is successfull, the used (({Item})) is ejected and ((|true|)) returned, 
((|false|)) otherwise.
=end

    def use_item
      if @inventory.active.apply(self) then
        @inventory.erase_active
        return true
      end
      return false
    end

=begin
--- Viking#update => nil
Updates ((<Viking>))'s internal state.
=end

    def update
      collect_items # sebere vsechno, na co narazi :o)

      unless (move_xy or move_y_only) then
        @log.warn "update: Viking #{name} cannot move in any axis. He could have stucked."
      end

      try_to_descend
      try_to_fall
      fall_if_head_on_the_ceiling
      update_rect_w_h

      @log.debug("update: #{@name}'s state: #{@state.to_s} #{@state.dump}")

      nil
    end



    private
    def move_xy
      next_pos = Rectangle.new(next_left, next_top, @rect.w, @rect.h)
      if @location.area_free?(next_pos) then
	@log.debug "update: Viking #{name}'s next position is all right."
        @rect = next_pos
        return true
      else
        return false
      end
    end

    private
    def move_y_only
      next_pos = Rectangle.new(@rect.left, next_top, @rect.w, @rect.h)
      if @location.area_free?(next_pos) then
        @log.debug "update: Viking #{name} cannot move horizontally, but his vertical coordinate was updated successfully."
        @rect = next_pos
        return true
      else
        @log.debug "update: Viking #{name} cannot move in any axis."
        return false
      end
    end

    private
    def try_to_fall
      # Zkusme, jestli by viking nemohl zacit padat.
      # Pokud muze zacit padat, zacne padat:
      if not @state.rising? and not @state.falling? and not on_some_surface?
	@state.fall
	@log.debug "update: #{@name} starts falling because there's a free space under him."
      end
    end

    private
    def try_to_descend
      if @state.falling? and on_some_surface? then
        @state.descend
        descend if on_ground?
      end
    end

    private
    def fall_if_head_on_the_ceiling
      head_area = next_position
      head_area.h = 20
      if @state.rising? and 
          not @location.area_free?(head_area) then
        @state.fall
      end
    end

    private
    def update_rect_w_h
      @rect.h = image.h
      @rect.w = image.w
    end

    private
    def next_left
      next_left = @rect.left + (velocity_horiz * @location.ticker.delta)
    end

    private
    def next_top
      next_top = @rect.top + (velocity_vertic * @location.ticker.delta)
    end

    private
    def next_position
      Rectangle.new next_left, next_top, @rect.w, @rect.h
    end

    private
    def velocity_horiz
      @state.velocity_horiz * BASE_VELOCITY
    end

    private
    def velocity_vertic
      @state.velocity_vertic * BASE_VELOCITY
    end

    private
    # Zjisti, jestli viking stoji na zemi (na pevne dlazdici)
    def on_ground?
      # stoji viking na stite?
      # return true if on_shield?
      # je pod vikingem volne misto?
      lowerpos = Rectangle.new(@rect.left, 
                               @rect.top + @location.ticker.delta * BASE_VELOCITY, 
                               @rect.w, 
                               @rect.h)
      return nil if @location.area_free?(lowerpos)
      # viking stoji na pevne zemi:
      return true
    end

    private
    def on_shield?
      shield = @location.sprites_on_rect(rect).find {|s| s.is_a? Platform}
      if shield and CollisionTest.bottom_collision?(rect, shield.rect) then
        return true
      else
        return false
      end
    end

    private
    def on_some_surface?
      on_ground? or on_shield?
    end

    private
    def collect_items
      @location.items_on_rect(rect).each do |i|
        @location.delete_item i
        @inventory.put i
      end
    end

    private
    def descend
      @rect.top += Map::TILE_SIZE - (@rect.bottom % Map::TILE_SIZE)
    end

  end # class Viking
end # module

require 'warior.rb'
require 'sprinter.rb'
require 'shielder.rb'
