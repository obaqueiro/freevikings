# topmenu.rb
# igneus 3.9.2005


module FreeVikings

  # Menu for the freeVikings game is built on the base of classes from
  # GameUI::Menus.
  # A top-level Menu class.
  # Actually it isn't really top-level, it builds an indirect parent Menu,
  # but this indirect parent is only used to ask the player if he really wants
  # to quit the menu - and the game.
  #
  # How do I make the 'indirect parent'? Look at MenuHidingButton.

  class TopMenu < GameUI::Menus::Menu

    MENU_WIDTH = 250

    include GameUI::Menus

    # TopMenu.new doesn't accept the same arguments as Menu.new, because
    # TopMenu has all the information needed and even creates it's own
    # parent menu.

    def initialize(surface)
      text_renderer = FreeVikings::FONTS['default']
      @x = surface.w/2 - MENU_WIDTH/2
      @y = 110
      @width = MENU_WIDTH

      # Dialog 'Exit game - yes/no?'. The indirect parent.
      exit_dialog = create_exit_dialog(surface, text_renderer)
      ActionButton.new(exit_dialog, "Yes", Proc.new {throw :game_exit})
      hider = MenuHidingButton.new(exit_dialog, "No")

      super(hider, "Menu", nil, nil, @x, @y, @width)
    end

    private

    def create_exit_dialog(surface, text_renderer)
      mn = Menu.new(nil, "Quit freeVikings?", surface, text_renderer, @x, @y, @width)
      return mn
    end

  end # class TopMenu

  # A MenuHidingButton looks like a normal MenuItem, but hides
  # a Menu or any other useful object in itself.
  # It makes it possible to 'rename' Menu - I use it to 'rename'
  # menu "Menu" to "No" in the "Exit game?" menu.

  class MenuHidingButton < GameUI::Menus::Menu

    def initialize(parent, text)
      unless parent
        raise "#{self.class.to_s} must have a real Menu parent."
      end

      @parent = parent
      @parent.add self
      @child = nil

      @image = create_image(text)
    end

    def add(menu_item)
      @child = menu_item
    end

    def enter
      @parent.quit
      @child.run
    end

    def run
      @parent.run
    end

    def quit
      @child.quit
    end

    def x
      @parent.x
    end

    def y
      @parent.y
    end

    def width
      @parent.width
    end

    def surface
      @parent.surface
    end

    def text_renderer
      @parent.text_renderer
    end

    def prepare
      # This must be empty. 'prepare' inherited from Menu is not good
      # for MenuHidingButton ...
    end
  end

  # A ChooseButton button which is synchronized with some option 
  # in FreeVikings::CONFIG.

  class FVConfiguratorButton < GameUI::Menus::ChooseButton

    # Arguments:
    # option_name:: name of configuration entry, e.g. 'Video/fullscreen'
    # choices_hash:: keys are displayed Strings, values are values
    # for the configuration entry - e.g. {'yes' => true, 'no' => false}

    def initialize(parent, text, option_name, choices_hash, change_proc=nil)
      super(parent, text, choices_hash.keys)
      @category_name, @option_name = option_name.split('/')
      @choices_hash = choices_hash
    end

    def prepare
      find_choice
    end

    private

    def changed(old_choice, new_choice)
      FreeVikings::CONFIG[@category_name][@option_name] = @choices_hash[self.value]
    end

    # Tries to find and set the choice which has been already 
    # chosen - e.g. by a commandline option

    def find_choice
      @choices.each_index do |i|
        key = @choices[i]
        begin
          if @choices_hash[key] == FreeVikings::CONFIG[@category_name][@option_name] then
            @choice = i
            return
          end
        rescue NoMethodError => e
          Log4r::Logger['init log'].error("FVConfiguratorButton: category '#{@category_name}', entry '#{@option_name}': "+e.message)
          raise
        end
      end
    end
  end

  class DisplayModeChooseButton < FVConfiguratorButton

    def initialize(parent, window)
      super(parent, "Mode", "Video/fullscreen",
            {"fullscreen" => true, "window" => false})
      @window = window
    end

    def changed(old_choice, new_choice)
      super(old_choice, new_choice)
      @window.toggle_fullscreen
    end
  end
end # module FreeVikings
