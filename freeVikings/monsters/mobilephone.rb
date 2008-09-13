# mobilephone.rb
# igneus 10.9.2008

module FreeVikings

  # MobilePhone is object which sometimes rings and when a viking
  # uses it (S key pressed), talks with him.
  # It is a Sprite and an ActiveObject.

  class MobilePhone < Sprite

    WIDTH = HEIGHT = 30

    # pos:: position of the mobile phone
    # receive_proc:: Proc executed if the phone is ringing and some viking
    # receives the call; it is given the viking as an argument

    def initialize(pos, receive_proc)
      super(pos)
      @state = "normal" # or "ringing"
      @receive_proc = receive_proc
    end

    attr_reader :state

    # Makes the phone ringing -> viking can receive call.

    def ring
      @state = 'ringing'
    end

    def activate
      if @state != 'ringing' then
        return
      end

      receive_call
    end

    def deactivate
    end

    def init_images
      @image = Model.new({'normal' => Image.load('handy1.tga'),
                           'ringing' => Image.load('handy2.tga')})
    end

    def register_in(location)
      location.add_sprite self
      location.add_active_object self
    end

    private

    # Called if phone's ringing and some viking activates it

    def receive_call
      @state = 'normal'
      receiver = @location.sprites_on_rect(rect).find {|s| s.kind_of? Viking}
      @receive_proc.call(receiver)
    end
  end
end
