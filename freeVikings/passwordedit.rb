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

    PASSWORD_LENGTH = 4

=begin
--- PasswordEdit.new(parent, label, ready_proc)
(({Proc})) ((|ready_proc|)) is called when the password is complete (is long
enough).
=end

    def initialize(parent, label, ready_proc)
      super(parent, label, PASSWORD_LENGTH)
      @ready_proc = ready_proc
    end

    private

    def read_events
      if @edit_place.value.size >= PASSWORD_LENGTH then
        FreeVikings::OPTIONS['startpassword'] = @edit_place.value.dup
        PASSWORD_LENGTH.times {@edit_place.backspace}

        begin
          @ready_proc.call
        rescue LevelSuite::UnknownPasswordException
        end
      end

      super
      @edit_place.value.upcase!
      @edit_place.refresh_image
    end

  end # class PasswordEdit
end # module FreeVikings
