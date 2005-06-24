# pausable.rb
# igneus 21.6.2005

module FreeVikings

=begin
= Pausable
Pausable is a mixin. It mixes into the objects two methods:
((<Pausable#pause>)) and ((<Pausable#unpause>)).
What do they do? The sprites usually update their position and then
save the time of the last update. (This is why freeVikings don't run fluently
on older machines.) Pause says the sprite: "Hi, Sprite, save your internal
state and go to bed, you won't be updated all the night."
On the other side unpause says: "Good morning! Take a shower and get dressed,
you must go to work!"

A notice for developers (for me at first): in freeVikings' sprite classes
a small synchronisation utility class, Ticker is widely used. But it cannot be
used here! You never know if the class which mixes ((<Pausable>)) in has
an attribute @location pointing to a Location with a Ticker!
Only Time can be used in ((<Pausable>)).
=end

  module Pausable

=begin
--- Pausable#pause
=end
    def pause
      @paused = Time.now.to_i # save a time when the sprite was paused
    end

=begin
--- Pausable#unpause
=end
    def unpause
      @paused = nil
      @last_update_time = Time.now.to_i
    end
  end # module Pausable
end # module FreeVikings
