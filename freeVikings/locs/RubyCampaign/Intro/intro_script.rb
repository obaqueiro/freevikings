# intro_script.rb
# igneus 2.9.2008

require 'door'
require 'lock'
require 'key'
# require 'monsters/lift'
require 'monsters/piranha'
require 'monsters/mobilephone'
require 'monsters/boat'
require 'talk'

LOCATION << (door = Door.new([440,200]))

# LOCATION << Lift.new(520,  [320, 160], LOCATION.theme)

LOCATION << Lock.new([460, 110], 
                     Proc.new {door.open},
                     Lock::GREEN)

LOCATION << Key.new([360, 280], Key::GREEN)

# Piranhas:
3.times {|i|
  LOCATION << Piranha.new([13*40+i*200, 8*40+20], Rectangle.new(13*40, 8*40+20, 22*40, 40)) 
}

# The phone's ringing.
# Baleog tells Erik to answer it.
# Erik talks with the desperate programmer for the first time.
# Phone's ringing again.
# Baleog tells Erik again to answer it.
# Erik taks with the programmer for the second time.
# Someone says 'Let's go'.

talk = Talk.new(File.open('locs/RubyCampaign/Intro/phone_talk.yaml'))

phone = MobilePhone.new([380, 110], Proc.new {|viking|
                          team = LOCATION.team
                          talk.start(team['erik'], 
                                     team['erik'],
                                     team['olaf'],
                                     team['baleog'])
                          LOCATION.talk = talk
                        })

phone.ring
LOCATION << phone

LOCATION << Boat.new([13*40, 8*40], [14*40, 35*40])
