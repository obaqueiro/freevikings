# menus.rb
# igneus 3.9.2005

=begin
= GameUI::Menus
A simple menu system for games written in Ruby using RUDL.
It's been developed to be used in the freeVikings game, but is
intended to be reused.
=end

unless defined?(RUDL)
  if defined?(Gem) then
    gem_original_require 'RUDL'
  else
    require 'RUDL'
  end
end

$:.push File.expand_path(File.dirname(__FILE__))
require 'menu.rb'

require 'items/selectablelabel.rb'
require 'items/quitbutton.rb'
require 'items/submitbutton.rb'
require 'items/choosebutton.rb'
require 'items/actionbutton.rb'
require 'items/textedit.rb'
require 'items/credits.rb'
require 'items/scrollingcredits.rb'
require 'items/select.rb'


###   Self-test:   ###

if __FILE__ == $0 then
  require '../textrenderer/textrenderer.rb'

  include GameUI::Menus

  win = RUDL::DisplaySurface.new [640, 480]

  text_renderer = TextRenderer.new(RUDL::TrueTypeFont.new('../textrenderer/fonts/adlibn.ttf', 16))

  menu = Menu.new(nil, "Menu mahajanga", win, text_renderer)

  # Add some menu items:
  SelectableLabel.new(menu, "Label")
  
  submenu = Menu.new(menu, "Submenu")
  SelectableLabel.new(submenu, "Schnupfen")

  # Submenu with sizes different from parent menu
  bigmenu = Menu.new(menu, "Big menu", nil, nil, nil, 300, 400)
  SelectableLabel.new(bigmenu, "Blaffff............")
  SelectableLabel.new(bigmenu, "This is such a very high item, that it splits into more lines even in such a huge menu!!!!!!!!!!!!")
  QuitButton.new(bigmenu)

  subsubmenu = Menu.new(submenu, "Subsubmenu", nil, submenu.text_renderer)
  SelectableLabel.new(subsubmenu, "Nothing")
  QuitButton.new(subsubmenu)

  QuitButton.new(submenu)

  Select.new(menu, "Select", [['ahoj', :ahoj], 
                              ['tschiao', 12], 
                              ['hello', 'value']])

  TextEdit.new(menu, "edit text", '', 12)
  ChooseButton.new(menu, "Sex", ['male', 'female', 'unknown'])

  credits_data = [['Alex A.', 'programming'], 
                  ['Carl C.', 'coffee support'],
                  ['Devis D.', 'graphics, music, money'],
                  ['Elvis Exploiter E. Expert Engonyama Erruptor', 
                   'his totally different vision of software development is extremely useful']]

  Credits.new(menu, credits_data)

  credits_data += [['Frank Foe', 'fate & fake pfeffer'],
                   ['George Grunge', 'musical support'],
                   ['Hans Hutchinsson', 'consultations'],
                   ['Isac Ibsen', 'inspirative sketches']]

  ScrollingCredits.new(menu, credits_data, 'ScrolCredits')

  QuitButton.new(menu)

  menu.run
end

