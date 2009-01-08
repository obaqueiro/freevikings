# select.rb
# igneus 8.1.2009

module GameUI
  module Menus

    # Select provides an alternative to ChooseButton:
    # It is similar to ChooseButton, because both offer a way to select
    # one of predefined values. With ChooseButton you select "in place",
    # Select opens a new menu instead, where you can see all the values
    # one next to the other.
    # (Actually I copied a lot of ChooseButton's code...)
    #
    # parent:: parent menu
    # text:: Select's title
    # choices:: Array of pairs [['to be displayed', 'internal value'],
    #                           ['show', :value]]
    # change_proc:: Proc to be called if Select is changed; may receive two
    #               arguments: old and new value of the Select

    class Select < Menu

      def initialize(parent, text, choices, change_proc=nil)
        super(parent, text)

        @choices = choices
        @choice = 0

        @images = create_images(text, choices)

        @change_proc = change_proc

        # create child objects:
        @choices.each_with_index do |c,i|
          SelectItem.new(self, c[0], i)
        end
      end

      # This method is called by children to tell Select which value 
      # was selected. Accepts integer.

      def select(i)
        if i >= @choices.size then
          raise ArgumentError, "Index '#{i}' out of range (#{@choices.size} items)"
        end

        do_change(@choice, i)
        @choice = i
        quit
      end

      def height
        @images[0].h
      end

      # Returns the selected value.

      def value
        @choices[@choice][1]
      end

      def image
        @images[@choice]
      end

      private

      def do_change(old, new)
        if @change_proc then
          @change_proc.call(old, new)
        end
      end

      def create_images(text, choices)
        imgs = []

        # create images used as a title in parent menu
        choices.each do |choice|
          imgs.push create_image(text + ":  " + choice[0])
        end

        return imgs
      end

      # Child item

      class SelectItem < MenuItem

        def initialize(parent, text, value)
          super(parent)
          @image = create_image(text)
          @value = value
        end

        def enter
          @parent.select @value
        end
      end
    end
  end
end
