# intro_script.rb
# igneus 2.9.2008

require 'door'
require 'lock'
require 'key'
# require 'monsters/mobilephone'
# require 'monsters/lift'
require 'monsters/piranha'
require 'monsters/boat'
require 'monsters/cottage'
require 'talk'
require 'story'
require 'ostruct'

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

LOCATION << Boat.new([13*40, 8*40], [14*40, 35*40])

# Cottages:
LOCATION << Cottage.new([39*40, 3*40], 'OLAF')
LOCATION << Cottage.new([45*40, 3*40], 'ERIK')
LOCATION << Cottage.new([51*40, 3*40], 'BALEOG')

# Door at the end and it's associated key&lock:
finaldoor = Door.new [57*40, 5*40]
LOCATION << finaldoor

LOCATION << Key.new([47*40, 2*40], Key::RED)
LOCATION << Lock.new([56*40, 6.5*40], Proc.new {finaldoor.open}, Lock::RED)

# ======================================================================
# Everything up to the end of file is about the initial story-telling...

class GiacommoProgrammer
  FAVOURITE_COLOUR = [100,100,100]
  def initialize
    s = RUDL::Surface.new([60,60])
    s.fill [100,100,100]
    handy = Image.load 'handy2.tga'
    s.blit handy.image, [s.w/2-handy.w/2, s.h/2-handy.h/2]
    @portrait = Image.wrap(s)
  end

  attr_reader :portrait
end

giacommo = GiacommoProgrammer.new

# load talks:
talk = Talk.new(File.open('locs/RubyCampaign/Intro/phone_talk.yaml'))
team = LOCATION.team
talk.start(team['erik'], giacommo, team['olaf'], team['baleog'])

talk2 = Talk.new(File.open('locs/RubyCampaign/Intro/second_phone_talk.yaml'))
talk2.start(team['erik'], giacommo, team['olaf'], team['baleog'])

# Set up Story:
story = Story.new do |s|
  s << Story::TextFrame.new("It was just another boring sunday afternoon and the three friends were sunbathing on the coast of the Arctic ocean, while Baleog's mobile phone rang.")

  Story::TalkFrame.talk_to_frames(talk).each {|f| 
    s << f
  }

  s << Story::TextFrame.new("But soon the phone was ringing again.")

  Story::TalkFrame.talk_to_frames(talk2).each {|f| 
    s << f
  }
end

endstory = Story.new do |s|
  s << Story::TextFrame.new("Sorry, this campaign currently doesn't contain any more levels. Check http://freevikings.sf.net for the next release!")
end

LOCATION.on_beginning = Proc.new { LOCATION.story = story }
LOCATION.on_exit = Proc.new { LOCATION.story = endstory }
