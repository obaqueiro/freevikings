# transportable.rb
# igneus 6.10.2005

module FreeVikings

  # Objects which include this mixin are able to be transported 
  # by the 'transporter
  # objects' (e.g. an escalator).

  module Transportable

    # This message tells the Transportable that it was found 
    # by some transporter
    # and it will be transported.

    def start_transport(transporter)
      @transported_by = transporter
    end

    # Called by Transporter.

    def end_transport(transporter)
      @transported_by = nil
    end

    # The transporter sends this message to all it's transported objects 
    # to tell
    # them they have been moved. delta_x and delta_y are changes
    # in x and y axis, transporter is the transporter instance which
    # is doing the transport.

    def transport_move(delta_x, delta_y, transporter)
      @rect.left += delta_x
      @rect.top += delta_y
    end

    # Transported Sprite should call this in every update to
    # check if it shouldn't end transport

    def update_transport
      return unless transported?

      unless @rect.expand(0,2).collides?(@transported_by.rect) then
        @transported_by.end_transport_of self
        # puts 'end'
      end
    end

    def transported?
      @transported_by != nil
    end
  end # module Transportable
end # module FreeVikings
