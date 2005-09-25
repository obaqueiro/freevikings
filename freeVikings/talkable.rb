# talkable.rb
# igneus 245.9.2005

=begin
= Talkable
((<Talkable>)) is a mixin module which provides basic mechanisms needed 
for taking a part in a (({Talk})).
=end

require 'textbox.rb'

module FreeVikings

  module Talkable

=begin
--- Talkable#say(sentence)
Puts a 'speak bubble' next to the talker's head.
This bubble disappears after 4 seconds.
=end

    def say(sentence)
      if defined? self.class::FAVOURITE_COLOUR then
        bg = self.class::FAVOURITE_COLOUR
      else
        bg = DisappearingTextBox::DEFAULT_BACKGROUND_COLOUR
      end
      textbox = DisappearingTextBox.new(@rect, 
                                        sentence,
                                        4,
                                        DisappearingTextBox::DEFAULT_FOREGROUND_COLOUR, 
                                        bg)
      @location.add_sprite textbox
    end
  end # module Talkable
end # module FreeVikings
