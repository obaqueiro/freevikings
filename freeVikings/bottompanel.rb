# bottompanel.rb
# igneus 25.6.2005

=begin
= BottomPanel
BottomPanel is what you can see on the bottom of the game window
during the game. It displays vikings' faces, energy and contents of their 
inventories.
=end

module FreeVikings

  class BottomPanel

    ACTIVE_SELECTION_BLINK_DELAY = 1

    VIKING_FACE_SIZE = 60
    INVENTORY_VIEW_SIZE = 60
    LIVE_SIZE = 20
    ITEM_SIZE = 30

    HEIGHT = VIKING_FACE_SIZE + LIVE_SIZE
    WIDTH = 640


=begin
--- BottomPanel#new(team)
Argument ((|team|)) is a Team of heroes who will be displayed on the panel.
=end

    def initialize(team)
      @team = team
      @image = RUDL::Surface.new [WIDTH, HEIGHT]
      @browse_inventory = false
      init_gfx
    end

=begin
--- BottomPanel#browse_inventory=(boolean)
--- BottomPanel#browse_inventory
--- BottomPanel#browse_inventory?

BottomPanel has two modes:
(1) browsing the inventory (the selection frame in the inventory of the
    active viking is blinking)
(2) normal
The mode can be set from outside.
=end

    attr_accessor :browse_inventory
    alias_method :browse_inventory?, :browse_inventory

=begin
--- BotomPanel#paint(surface)
Paints itself onto the ((|surface|)). Doesn't worry about the ((|surface|))'s
size.
=end

    def paint(surface)
      # vybarveni pozadi pro podobenky vikingu:
      surface.fill([60,60,60])
      i = 0

      time = Time.now.to_f
      @team.each { |vik|
        # paint face:
        face_position = [i * (INVENTORY_VIEW_SIZE + VIKING_FACE_SIZE), 0]
	surface.blit(@face_bg, face_position)
        portrait_img = if @team.active == vik && vik.alive? then
                         vik.portrait.active
                       elsif not vik.alive?
                         vik.portrait.kaput
                       else
                         vik.portrait.unactive
                       end
        surface.blit(portrait_img, face_position)
        # paint the lives:
        lives_y = VIKING_FACE_SIZE
        vik.energy.times {|j| 
          live_position = [face_position[0] + j * LIVE_SIZE, lives_y]
          surface.blit(@energy_punkt, live_position)
        }
        # paint inventory contents:
        item_positions = [[0,0],        [ITEM_SIZE,0],
                          [0,ITEM_SIZE],[ITEM_SIZE, ITEM_SIZE]]
        0.upto(3) do |k|
          item_position = [item_positions[k][0] + face_position[0] + VIKING_FACE_SIZE, item_positions[k][1]]
          surface.blit(@item_bg, item_position)
          unless vik.inventory[k].null?
            surface.blit(vik.inventory[k].image, item_position)
          end
          if vik.inventory.active_index == k then
            if (not browse_inventory?) or 
                (browse_inventory? and (not @team.active == vik or time % ACTIVE_SELECTION_BLINK_DELAY > 0.2))
              surface.blit(@selection_box, item_position)
            end
          end
        end

	i += 1
      }
    end

=begin
--- BottomPanel#image
Returns a RUDL::Surface with a updated contents of self.
=end

    def image
      paint(@image)
      @image
    end

    private

    def init_gfx
      @face_bg = RUDL::Surface.load_new(GFX_DIR+'/face_bg.tga')
      @item_bg = RUDL::Surface.load_new(GFX_DIR+'/item_bg.tga')
      @selection_box = RUDL::Surface.load_new(GFX_DIR+'/selection.tga')
      @energy_punkt = RUDL::Surface.load_new(GFX_DIR+'/energypunkt.tga')
    end # init_display

  end # class BottomPanel
end # module FreeVikings
