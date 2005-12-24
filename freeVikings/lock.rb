# lock.rb
# igneus 30.7.2005

=begin
= NAME
Lock

= DESCRIPTION
((<Lock>)) is a Static object which waits until someone unlocks it.
Then some action is usually performed.
To unlock the ((<Lock>)) one needs a (({Key})). There are several
colour variants of the (({Key}))s and ((<Lock>))s and to unlock
a ((<Lock>)) you need a (({Key})) of the same colour.

= Superclass
Entity
=end

require 'staticobject.rb'

module FreeVikings

  class Lock < Entity

=begin
= Included mixins
StaticObject
=end

    include StaticObject

=begin
= Constants

== Lock::Colour
Module, which contains symbolic constants for Locks & Keys colours.
This module is included in classes ((<Lock>)) and (({Key})), so you
don't have to write

(({Lock::Colour::BLUE}))

but

(({Lock::BLUE}))

Listing of the constants:
(({RED})), (({GREEN})), (({BLUE}))
=end

    module Colour
      RED = 1
      GREEN = 2
      BLUE = 3
    end

    include Colour

# Hash where Colour constants are keys and corresponding Image objects
# values.

    @@images = {RED => Image.load('lock_red.tga'),
                GREEN => Image.load('lock_green.tga'),
                BLUE => Image.load('lock_blue.tga')}

=begin
= Class methods

--- Lock.new(position, unlock_action=Proc.new {}, colour=RED)
Arguments:
* ((|position|)) is the same as at any other (({Entity})).
* ((|unlock_action|)) is an object which responds to (({call})) method or
  (({nil})). It is called when the ((<Lock>)) is successfully unlocked.
* ((|colour|)) should be one of the ((<Lock::Colour>)) constants.
  Otherwise unexpectable things can happen.
=end

    def initialize(position, unlock_action=Proc.new {}, colour=RED)
      super(position)
      @locked = true
      @colour = colour
      @unlock_action = unlock_action
      @image = @@images[@colour]
    end

=begin
= Instance methods

--- Lock#colour
Returns the ((<Lock>))'s colour (one of the constants from ((<Lock::Colour>))).
=end

    attr_reader :colour

=begin
--- Lock#unlock_action=(proc)
Sets the Proc (or any other object which responds to (({call}))) which is
called when the ((<Lock>)) is unlocked successfully.
=end

    attr_writer :unlock_action

=begin
--- Lock#locked?
Answers the question "is the ((<Lock>)) locked?" by ((|true|)) or ((|false|)).
=end

    def locked?
      @locked
    end

=begin
--- Lock#unlock(key)
Argument ((|key|)) must be of type (({Key})), otherwise 
(({AttemptToUnlockByANonKeyToolException})) is thrown.
If the (({Key})) and the ((<Lock>)) are of the same type, the ((<Lock>))
is unlocked.
Returns ((|true|)) if the unlock operation is successfull,
((|false|)) otherwise.
=end

    def unlock(key)
      unless key.kind_of?(Key)
        raise AttemptToUnlockByANonKeyToolException, "#{key.class} is not a Key type."
      end

      if key.colour == @colour then
        @locked = false
        @unlock_action.call if @unlock_action
      end

      return ! @locked
    end

=begin
= Public internal classes

--- Lock::AttemptToUnlockByANonKeyToolException
((<Lock#unlock>)) throws this exception if the given argument isn't of any 
Key type.
=end

    class AttemptToUnlockByANonKeyToolException < RuntimeError
    end # class AttemptToUnlockByANonKeyTool
  end # class Lock
end # module FreeVikings
