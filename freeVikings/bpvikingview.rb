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

      def initialize(viking, position)
        @viking = viking
        @viking.view = self

        @rect = Rectangle.new position[0], position[1], WIDTH, HEIGHT
        @portrait_rect = Rectangle.new(@rect.left, @rect.top, 
                                       VIKING_FACE_SIZE, VIKING_FACE_SIZE)
        @inventory_rect = Rectangle.new(@rect.left+VIKING_FACE_SIZE, @rect.top,
                                        INVENTORY_VIEW_SIZE,
                                        INVENTORY_VIEW_SIZE)

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
        lives_y = VIKING_FACE_SIZE
        @viking.energy.times {|j| 
          live_position = [@rect.left + j*LIFE_SIZE, lives_y]
          surface.blit(@energy_punkt, live_position)
        }
      end

      def paint_inventory(surface)
        inventory_view_pos = [@rect.left+VIKING_FACE_SIZE, @rect.top]

        time = Time.now.to_f

        inventory = @viking.inventory

        0.upto(inventory.num_slots-1) do |k|
          item = inventory[k]

          ip = ITEM_POSITIONS[k]
          item_position = [ip[0] + @rect.left + VIKING_FACE_SIZE, ip[1]]

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
        @face_bg = RUDL::Surface.load_new(GFX_DIR+'/face_bg.tga')
        @energy_punkt = RUDL::Surface.load_new(GFX_DIR+'/energypunkt.png')

        @item_bg = RUDL::Surface.load_new(GFX_DIR+'/item_bg.tga')
        @selection_box_yellow = RUDL::Surface.load_new(GFX_DIR+'/selection.tga')
        @selection_box_green = RUDL::Surface.load_new(GFX_DIR+'/selection_exchange.tga')
      end

      # Vikings use this when they have no view (mainly in tests)

      class NullView
        def update_view
        end
      end
    end
  end
end
