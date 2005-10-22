# passwordedit.rb
# igneus 10.9.2005

=begin
= PasswordEdit
A modified text-editing widget for freeVikings menu.
If a good password is inserted, location with that password is started.
Otherwise parent menu is entered.
=end

require 'gameui'

module FreeVikings

  class PasswordEdit < GameUI::Menus::TextEdit

    include GameUI::Menus

    PASSWORD_LENGTH = 4

=begin
--- PasswordEdit.new(parent, label, ready_proc)
(({Proc})) ((|ready_proc|)) is called when the password is complete (is long
enough).
=end

    def initialize(parent, label, value, ready_proc)
      super(parent, label, value, PASSWORD_LENGTH, 
            TextEdit::USE_OK_BUTTON|TextEdit::USE_BACK_BUTTON)
      @ready_proc = ready_proc
    end

    def submit
      if @edit_place.value.size >= PASSWORD_LENGTH then
        FreeVikings::OPTIONS['startpassword'] = String.new(@edit_place.value)
        PASSWORD_LENGTH.times {@edit_place.backspace}

        begin
          @ready_proc.call
        rescue LevelSuite::UnknownPasswordException
        end
      end
    end

    private

    def read_events
      super
      begin
        @edit_place.value.upcase!
      rescue TypeError
        # TypeError occurs here when the upcased strong is frozen
        # (when the password was given from the command line).
        @edit_place.value = @edit_place.value.upcase
      end
      @edit_place.refresh_image
    end
  end # class PasswordEdit
end # module FreeVikings
