# menus.rb
# igneus 3.9.2005

=begin
= GameUI::Menus
A simple menu system for games written in Ruby using RUDL.
It's been developed to be used in the freeVikings game, but is
intended to be reused.
=end

unless defined?(RUDL)
  require 'RUDL'
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


###   Self-test:   ###

if __FILE__ == $0 then
  require '../textrenderer/textrenderer.rb'

  include GameUI::Menus

  win = RUDL::DisplaySurface.new [640, 480]

  text_renderer = TextRenderer.new(RUDL::TrueTypeFont.new('../textrenderer/fonts/adlibn.ttf', 16))

  menu = Menu.new(nil, "Menu mahajanga", win, text_renderer)

  # Add some menu items:
  SelectableLabel.new(menu, "Label")
  
  submenu = Menu.new(menu, "Submenu", nil, menu.text_renderer)
  SelectableLabel.new(submenu, "Schnupfen")

  subsubmenu = Menu.new(submenu, "Subsubmenu", nil, submenu.text_renderer)
  SelectableLabel.new(subsubmenu, "Nothing")
  QuitButton.new(subsubmenu)

  QuitButton.new(submenu)

  TextEdit.new(menu, "Name", '', 12)
  ChooseButton.new(menu, "Sex", ['male', 'female', 'unknown'])
  Credits.new(menu, [['Alex A.', 'programming'], 
                     #['Carl C.', 'coffee support'],
                     #['Devis D.', 'graphics, music, money'],
                     ['Elvis Exploiter E. Expert Engonyama Erruptor', 
                      'his totally different vision of software development is extremely useful']])

  QuitButton.new(menu)

  menu.run
end

