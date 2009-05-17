# bpvikingview.rb
# igneus 27.11.2008

module FreeVikings
  class BottomPanel

    # Shows viking's portrait, lives and inventory content in the
    # BottomPanel

    class VikingView

      ACTIVE_SELECTION_BLINK_DELAY = 1
      
      VIKING_FACE_SIZE = 60
      LIFE_SIZE = 20
      ITEM_SIZE = 30
      INVENTORY_VIEW_SIZE = 2 * ITEM_SIZE

      WIDTH = VIKING_FACE_SIZE + INVENTORY_VIEW_SIZE
      HEIGHT = VIKING_FACE_SIZE + LIFE_SIZE

      # Positions of items in inventory
      ITEM_POSITIONS = [[0,0],        [ITEM_SIZE,0],
                        [0,ITEM_SIZE],[ITEM_SIZE, ITEM_SIZE]]

      # Colour of highlighted viking's background
      HIGHLIGHT_COLOUR = [150, 100, 100]

      # How many energy points could theoretically be displayed
      MAX_DISPLAYABLE_ENERGY = 5

      def initialize(viking, position)
        @viking = viking
        @viking.view = self

        @rect = Rectangle.new position[0], position[1], WIDTH, HEIGHT

        # rects of portrait and inventory are relative to @rect =>
        # they don't need to be updated when view is moved
        portrait_abs = Rectangle.new(@rect.left, @rect.top, 
                                     VIKING_FACE_SIZE, VIKING_FACE_SIZE)
        @portrait_rect = RelativeRectangle.new2(@rect, portrait_abs)
        inventory_abs = Rectangle.new(@rect.left+VIKING_FACE_SIZE, @rect.top,
                                      INVENTORY_VIEW_SIZE,
                                      INVENTORY_VIEW_SIZE)
        @inventory_rect = RelativeRectangle.new2(@rect, inventory_abs)

        @active = false
        @mode = :normal
        @highlighted = false

        @need_update = false

        init_gfx
      end

      attr_reader :viking

      # == Methods about position of view

      attr_reader :rect

      # Returns Boolean.
      # Says if given position is inside viking's portrait.

      def pos_in_portrait?(pos)
        return @portrait_rect.point_inside?(pos)
      end

      # Returns Boolean.
      # Says if given position is inside viking's inventory.

      def pos_in_inventory?(pos)
        return @inventory_rect.point_inside?(pos)
      end

      # Returns index of item in inventory displayed at given position or nil.
      # Nil is returned both if position is outside the inventory and if
      # clicked inventory position is empty.

      def pos_in_item?(pos)
        unless pos_in_inventory?(pos)
          return nil
        end

        xi = (pos[0] - @inventory_rect.left) / ITEM_SIZE
        yi = (pos[1] - @inventory_rect.top) / ITEM_SIZE
        i = yi*2 + xi

        if @viking.inventory.at(i).null? then
          return nil
        else
          return i
        end
      end

      # == "Graphics update interface" for BottomPanel

      # Says if something important has been changed and BottomPanel
      # should be repainted

      def need_update?
        @need_update
      end

      # Tells VikingView that the requested update has been done

      def updated
        @need_update = false
      end

      def paint(surface)
        paint_face(surface)
        paint_lives(surface)
        paint_inventory(surface)
      end

      private

      # == Painting tasks

      def paint_face(surface)
        face_position = @rect.top_left
        if @highlighted then
          surface.fill HIGHLIGHT_COLOUR, [face_position[0], face_position[1], @face_bg.w, @face_bg.h]
        else
          surface.blit(@face_bg, face_position)
        end
        portrait_img = if @active then
                         @viking.portrait.active
                       elsif not @viking.alive?
                         @viking.portrait.kaput
                       else
                         @viking.portrait.unactive
                       end

        surface.blit(portrait_img, face_position)
      end

      def paint_lives(surface)
        lives_y = @rect.top + VIKING_FACE_SIZE

        MAX_DISPLAYABLE_ENERGY.times {|j|
          # position of "live background"
          live_position = [@rect.left + j*LIFE_SIZE, lives_y]
          # position of the red/blue/grey point itself
          point_position = [live_position[0]+2, live_position[1]+2]

          l = j+1 # iterations count from 0, energy points from 1

          if l <= Viking::MAX_ENERGY then
            surface.blit(@energy_bg, live_position)
            if @viking.energy >= l then
              # red
              surface.blit(@energy, point_position)
            else
              # grey
              surface.blit(@energy_lost, point_position)
            end
          elsif @viking.energy >= l then
            # extra (blue)
            surface.blit(@energy_bg, live_position)
            surface.blit(@energy_extra, point_position)
          else
            break
          end
        }
      end

      def paint_inventory(surface)
        time = Time.now.to_f

        inventory = @viking.inventory

        inventory_x = @rect.left+VIKING_FACE_SIZE
        inventory_y = @rect.top

        0.upto(inventory.num_slots-1) do |k|
          item = inventory[k]

          ip = ITEM_POSITIONS[k]
          item_position = [inventory_x + ip[0], inventory_y + ip[1]]

          surface.blit(@item_bg, item_position)
          unless item.null?
            surface.blit(item.image, item_position)
          end
          if inventory.active_index == k then
            if show_selection_box? then
              surface.blit(selection_box, item_position)
            end
          end
        end
      end

      public

      # == Interface of notification by Viking

      # method called by Inventory and Viking (VikingView is observer 
      # of Viking and his Inventory)

      def update_view
        @need_update = true
      end

      # == State interface for BottomPanel

      # === Set viking view active (colourful portrait) or unactive

      def activate
        @need_update = true
        @active = true
      end

      def deactivate
        @need_update = true
        @active = false
      end

      # === Set inventory select box mode

      def normal
        @need_update = true
        @mode = :normal
      end

      def browse
        @need_update = true
        @mode = :browsing
      end

      def exchange
        @need_update = true
        @mode = :exchange
      end

      # === Set viking view highlighted (for items exchange mode)

      def highlight
        @highlighted = true
      end

      def unhighlight
        @highlighted = false
      end

      private

      # Should the selection box be displayed? (Calculates with blinking.)

      def show_selection_box?
        if @active and
            (@mode == :browsing || @mode == :exchange) and 
            (Time.now.to_f % ACTIVE_SELECTION_BLINK_DELAY < 0.2) then
          return false
        end

        return true
      end

      # Returns an image for the current type of selection box.

      def selection_box
        if @mode == :exchange and @active then
          return @selection_box_green
        else
          return @selection_box_yellow
        end
      end

      def init_gfx
        @face_bg = RUDL::Surface.load_new(GFX_DIR+'/panel/face_bg.png')

        @energy_bg = RUDL::Surface.load_new(GFX_DIR+'/panel/energyp_background.png')
        @energy = RUDL::Surface.load_new(GFX_DIR+'/panel/energypoint_red.png')
        @energy_extra = RUDL::Surface.load_new(GFX_DIR+'/panel/energypoint_blue.png')
        @energy_lost = RUDL::Surface.load_new(GFX_DIR+'/panel/energypoint_grey.png')

        @item_bg = RUDL::Surface.load_new(GFX_DIR+'/panel/item01.png')
        @selection_box_yellow = RUDL::Surface.load_new(GFX_DIR+'/panel/yellow_box.png')
        @selection_box_green = RUDL::Surface.load_new(GFX_DIR+'/panel/green_box.png')
      end

      # Vikings use this when they have no view (mainly in tests)

      class NullView
        def update_view
        end
      end
    end
  end
end
