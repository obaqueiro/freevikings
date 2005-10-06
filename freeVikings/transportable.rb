# transportable.rb
# igneus 6.10.2005

=begin
= Transportable
Objects which include this mixin are able to be transported by the 'transporter
objects' (e.g. an escalator).
=end

module FreeVikings

  module Transportable

=begin
--- Transportable#start_transport(transporter)
This message tells the Transportable that it was found by some transporter
and it will be transported.
=end

    def start_transport(transporter)
      @transported_by = transporter
    end

=begin
--- Transportable#end_transport(transporter)
=end

    def end_transport(transporter)
      @transported_by = nil
    end

=begin
--- Transportable#transport_move(delta_x, delta_y, transporter)
The transporter sends this message to all it's transported objects to tell
them they have been moved. ((|delta_x|)) and ((|delta_y|)) are changes
in x and y axis, ((|transporter|)) is the transporter instance which
is doing the transport.
=end

    def transport_move(delta_x, delta_y, transporter)
      @rect = Rectangle.new(@rect.left+delta_x, @rect.top+delta_y, 
                            @rect.w, @rect.h)
    end
  end # module Transportable
end # module FreeVikings
