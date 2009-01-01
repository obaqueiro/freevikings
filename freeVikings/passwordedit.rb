# passwordedit.rb
# igneus 10.9.2005

=begin
= PasswordEdit
A modified text-editing widget for freeVikings menu.
If a good password is inserted, location with that password is started.
Otherwise parent menu is entered.
=end

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
        FreeVikings::CONFIG['Game']['start password'] = String.new(@edit_place.value)
        PASSWORD_LENGTH.times {@edit_place.backspace}

        begin
          @ready_proc.call
        rescue LevelSuite::UnknownPasswordException
        end
      end
    end

    def prepare
      super

      # pre-insert the last used password if any
      if password = FreeVikings::CONFIG['Game']['start password'] then
        @edit_place.value = password
      end
    end

    private

    def read_events
      super

      # @edit_place.value.upcase! isn't possible here because
      # if the password is given from the command line it is frozen.
      @edit_place.value = @edit_place.value.upcase

      @edit_place.refresh_image
    end
  end # class PasswordEdit
end # module FreeVikings
