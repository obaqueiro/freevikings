# gameui.rb
# igneus 3.9.2005

=begin
= GameUI
((<GameUI>)) is a set of classes which should be helpful for developers
of Ruby written games, especially for those who want to have some
sort of boring user interface (text menus etc.) in their games using RUDL.
=end

# $:.push File.expand_path(File.dirname(__FILE__))

require 'gameui/textrenderer/textrenderer.rb'
require 'gameui/menu/menus.rb'
