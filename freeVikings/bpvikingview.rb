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

      def initialize(viking, position)
        @viking = viking
        @rect = Rectangle.new position[0], position[1], WIDTH, HEIGHT

        @active = false
        @mode = :normal

        init_gfx
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
        surface.blit(@face_bg, face_position)
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

      # == Set viking view active (colourful portrait) or unactive

      def activate
        @active = true
      end

      def deactivate
        @active = false
      end

      # == Set inventory select box mode

      def normal
        @mode = :normal
      end

      def browse
        @mode = :browsing
      end

      def exchange
        @mode = :exchange
      end

      private

      # Should the selection box be displayed? (Calculates with blinking.)

      def show_selection_box?
        if @mode == :normal
          return true
        end

        unless @active
          return true
        end

        if (@active and 
            (@mode == :browsing || @mode == :exchange) and 
            (Time.now.to_f % ACTIVE_SELECTION_BLINK_DELAY > 0.2)) then
          return true
        end

        return false
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
    end
  end
end
