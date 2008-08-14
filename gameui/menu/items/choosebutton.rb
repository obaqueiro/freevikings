# choosebutton.rb
# igneus 3.9.2005

=begin
= GameUI::Menus::ChooseButton
This (({MenuItem})) lets the user select between some predefined
values by pressing left and right key.
=end

module GameUI
  module Menus

    class ChooseButton < MenuItem

=begin
--- ChooseButton.new(parent, text, choices, change_proc=nil)
(({Array})) choices contains all the possible values. All of them must respond 
to (({to_s})).
((|change_proc|)) is a voluntary argument; it should be a (({Proc})) which
accepts two parameters. It's called whenever the choice is changed
and the old choice are given to it.
=end

      def initialize(parent, text, choices, change_proc=nil)
        super(parent)

        @choices = choices
        @choice = 0

        @images = create_images(text, choices)

        @change_proc = change_proc
      end

=begin
--- ChooseButton#value
Returns the selected value.
=end

      def value
        @choices[@choice]
      end

      def image
        @images[@choice]
      end

=begin
--- ChooseButton#less
Selects the previous value.
=end

      def less
        old = @choice # @choice is a Fixnum, not a normal object
        @choice -= 1
        @choice = @choices.size - 1 if @choice < 0
        do_change(old, @choice)
      end

=begin
--- ChooseButton#more
Selects the next value.
=end


      def more
        old = @choice # @choice is a Fixnum, not a normal object
        @choice += 1
        @choice = 0 if @choice >= @images.size

        do_change(old, @choice)
      end

=begin
--- ChooseButton#enter
Synonym to ((<ChooseButton#more>)).
=end

      alias_method :enter, :more

      private

=begin
--- ChooseButton#changed(old_choice, choice_now)
This is a PRIVATE method.
It is called whenever the choice is changed.
You can either redefine this method or give the proc to ((<ChooseButton.new>))
to treat the change.
=end

      def changed(old_choice, choice_now)
      end

      def do_change(old, new)
        changed(old, new)
        if @change_proc then
          @change_proc.call(old, new)
        end
      end

      def create_images(text, choices)
        imgs = []
        choices.each do |choice|
          imgs.push create_image(text + ":  " + choice.to_s)
        end

        return imgs
      end
    end
  end
end
