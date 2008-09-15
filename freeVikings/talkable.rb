# talkable.rb
# igneus 245.9.2005

require 'textbox.rb'

module FreeVikings

  # Talkable is a mixin module which provides basic mechanisms needed 
  # for taking a part in a Talk.
  #
  # In the class including Talkable constant FAVOURITE_COLOUR
  # should be defined. It must be a 3-element Array of numbers
  # from range 0..255 - it defines colour of "sentence textboxes".
  # E.g. [255,0,0] makes them red.

  module Talkable

    # Puts a 'speak bubble' next to the talker's head.
    # This bubble disappears as soon as Talkable#silence_please is called.

    def say(sentence)
      if defined? self.class::FAVOURITE_COLOUR then
        bg = self.class::FAVOURITE_COLOUR
      else
        bg = DisappearingTextBox::DEFAULT_BACKGROUND_COLOUR
      end
      @talkable_textbox = TextBox.new(@rect, 
                                      sentence,
                                      TextBox::DEFAULT_FOREGROUND_COLOUR, 
                                      bg)
      @location.add_sprite @talkable_textbox
    end

    # Hides the previously shown textbox

    def silence_please
      if @talkable_textbox then
        @talkable_textbox.disappear
        @talkable_textbox = nil
      end
    end
  end # module Talkable
end # module FreeVikings
