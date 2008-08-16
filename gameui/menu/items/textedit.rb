# textedit.rb
# igneus 3.9.2005

module GameUI
  module Menus

    class TextEdit < Menu

      INPUT_MAX_CHARS = 25

      # flags to be or-ed together in any combination in the last argument
      # for TextEdit.new
      USE_OK_BUTTON = 01
      USE_BACK_BUTTON = 02

      def initialize(parent, label, value='', max_chars=INPUT_MAX_CHARS, 
                     flags=USE_BACK_BUTTON)
        super(parent, label, nil, nil)

        @label = label
        @max_chars = max_chars

        @edit_place = EditPlace.new(self, (value ? value : ""))

        SubmitButton.new(self) if (flags & USE_OK_BUTTON) != 0
        QuitButton.new(self) if (flags & USE_BACK_BUTTON) != 0

        refresh_image
      end

      attr_reader :max_chars

      def read_events
        events = super

        if @selected == 0 then # EditPlace is selected
          events.each do |event|
            if event.is_a? KeyDownEvent then
              case event.key
              when K_BACKSPACE
                @edit_place.backspace
              when K_a
                @edit_place.add_str 'a'
              when K_b
                @edit_place.add_str 'b'
              when K_c
                @edit_place.add_str 'c'
              when K_d
                @edit_place.add_str 'd'
              when K_e
                @edit_place.add_str 'e'
              when K_f
                @edit_place.add_str 'f'
              when K_g
                @edit_place.add_str 'g'
              when K_h
                @edit_place.add_str 'h'
              when K_i
                @edit_place.add_str 'i'
              when K_j
                @edit_place.add_str 'j'
              when K_k
                @edit_place.add_str 'k'
              when K_l
                @edit_place.add_str 'l'
              when K_m
                @edit_place.add_str 'm'
              when K_n
                @edit_place.add_str 'n'
              when K_o
                @edit_place.add_str 'o'
              when K_p
                @edit_place.add_str 'p'
              when K_q
                @edit_place.add_str 'q'
              when K_r
                @edit_place.add_str 'r'
              when K_s
                @edit_place.add_str 's'
              when K_t
                @edit_place.add_str 't'
              when K_u
                @edit_place.add_str 'u'
              when K_v
                @edit_place.add_str 'v'
              when K_w
                @edit_place.add_str 'w'
              when K_x
                @edit_place.add_str 'x'
              when K_y
                @edit_place.add_str 'y'
              when K_z
                @edit_place.add_str 'z'
              end
            end
          end
        end

        return events
      end

      def run
        refresh_image
        super
      end

      def quit
        refresh_image
        super 
      end

      alias_method :submit, :quit

      private

      def refresh_image
        @image = create_image(@label + ': ' + @edit_place.value)
      end

      class EditPlace < MenuItem
        def initialize(parent, text='')
          super(parent)
          @input_text = text
          refresh_image
        end

        def add_str(str)
          @input_text += str unless (@input_text + str).size > @parent.max_chars
          refresh_image
        end

        def enter
          @parent.submit
        end

        def backspace
          @input_text = @input_text.chop
          refresh_image
        end

        def value
          @input_text
        end

        def value=(v)
          @input_text = v
        end

        def refresh_image
          begin
            @image = create_image(@input_text)
          rescue SDLError
            @image = RUDL::Surface.new
          end
        end
      end # class EditPlace
    end
  end
end
