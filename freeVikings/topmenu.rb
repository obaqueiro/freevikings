# topmenu.rb
# igneus 3.9.2005

require 'gameui/gameui.rb'

=begin
= FreeVikings game menu
Menu for the freeVikings game is built on the base of classes from
(({GameUI::Menus})).
=end

module FreeVikings

=begin
== TopMenu
A top-level (({Menu})) class.
Actually it isn't really top-level, it builds an indirect parent (({Menu})),
but this indirect parent is only used to ask the player if he really wants
to quit the menu - and the game.

How do I make the 'indirect parent'? Look at ((<MenuHidingButton>)).
=end

  class TopMenu < GameUI::Menus::Menu

    MENU_WIDTH = 300

    include GameUI::Menus

=begin
--- TopMenu.new(surface)
See, you can't use ((<TopMenu>)) as any other (({Menu}))'s child.
Or, it isn't so much simple.
=end

    def initialize(surface)
      text_renderer = FreeVikings::FONTS['default']
      @x = surface.w/2 - MENU_WIDTH/2
      @y = 110
      @width = 200

      # Dialog 'Exit game - yes/no?'. The indirect parent.
      exit_dialog = create_exit_dialog(surface, text_renderer)
      ActionButton.new(exit_dialog, "Yes", Proc.new {throw :game_exit})
      hider = MenuHidingButton.new(exit_dialog, "No")

      super(hider, "Menu", nil, nil)
    end

    private

    def create_exit_dialog(surface, text_renderer)
      mn = Menu.new(nil, "Quit freeVikings?", surface, text_renderer, @x, @y, @width)
      return mn
    end

  end # class TopMenu

=begin
== MenuHidingButton
A ((<MenuHidingButton>)) looks like a normal (({MenuItem})), but hides
a (({Menu})) or any other useful object in itself.
It makes it possible to 'rename' (({Menu})) - I use it to 'rename'
menu "Menu" to "No" in the "Exit game?" menu.
=end

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
  end

=begin
== FVConfiguratorButton
A (({ChooseButton})) button which is synchronized with some option 
in (({FreeVikings::OPTIONS})).
=end

  class FVConfiguratorButton < GameUI::Menus::ChooseButton

=begin
--- FVConfiguratorButton.new(parent, text, option_name, choices_hash)
Arguments:
* ((|option_name|)) - a key into (({FreeVikings::OPTIONS})) - e.g. 
  'display_fps'
* ((|choices_hash|)) - keys are displayed (({String}))s, values are values
  for (({FreeVikings::OPTIONS})) - e.g. (({ {'yes' => true, 'no' => false} }))
=end

    def initialize(parent, text, option_name, choices_hash)
      super(parent, text, choices_hash.keys)
      @option_name = option_name
      @choices_hash = choices_hash
      find_choice
    end

    private

    def changed(old_choice, new_choice)
      FreeVikings::OPTIONS[@option_name] = @choices_hash[self.value]
    end

    # Tries to find and set the choice which has been already 
    # chosen - e.g. by a commandline option

    def find_choice
      @choices.each_index do |i|
        key = @choices[i]
        if @choices_hash[key] == FreeVikings::OPTIONS[@option_name] then
          @choice = i
          return
        end
      end
    end
  end
end # module FreeVikings
