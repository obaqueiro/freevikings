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
=end

  class TopMenu < GameUI::Menus::Menu

    include GameUI::Menus

    def initialize(surface)
      text_renderer = FreeVikings::FONTS['default']

      # Dialog 'Exit game - yes/no?'      
      exit_dialog = create_exit_dialog(surface, text_renderer)
      ActionButton.new(exit_dialog, "Yes", Proc.new {throw :game_exit})
      hider = MenuHidingButton.new(exit_dialog, "No")

      super(hider, "Menu", surface, text_renderer)
    end

    private

    def create_exit_dialog(surface, text_renderer)
      mn = Menu.new(nil, "Quit freeVikings?", surface, text_renderer)
      return mn
    end

  end # class TopMenu

  class MenuHidingButton < GameUI::Menus::MenuItem

    def initialize(parent, text)
      super(parent)
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
  end

end # module FreeVikings
