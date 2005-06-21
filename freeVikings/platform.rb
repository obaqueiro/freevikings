# platform.rb
# igneus 19.6.2005

require 'sprite.rb'

module FreeVikings

=begin
= Platform
Platform is a very useful object. It's an object you can stand on.
A typical example of Platform is a Shield.
Someone could get confused here. FreeVikings are a platform game.
So all the platforms in the game should be instances of a Platform?
It would be very inefficient. Most of the platforms in the game
are made of map's tiles. Platform objects are there for platforms which
move or do any other nifty games.
=end
  module Platform
  end # class Platform
end # module FreeVikings
