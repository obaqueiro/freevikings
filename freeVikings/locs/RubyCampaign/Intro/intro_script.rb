# intro_script.rb
# igneus 2.9.2008

require 'door'
require 'lock'
require 'key'
# require 'monsters/lift'
require 'monsters/piranha'
# require 'monsters/mobilephone'
require 'monsters/boat'
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

# Everything up to the end of file is about the initial story-telling...

# A small modification to class Talk:
class FreeVikings::Talk
  def to_storyframes
    unless running?
      raise "Need speakers!"
    end

    frames = []

    @talk.each do |node|
      frames << TalkFrame.new(@speakers[node['speaker']], node['say'])
    end

    return frames
  end
end

class TalkFrame < FreeVikings::Story::Frame

  TEXT_WIDTH = 300
  LEFT = Story::Frame::WIDTH/2-TEXT_WIDTH/2 + 30
  TOP = 100

  def initialize(speaker, sentence)
    super()

    portrait = speaker.portrait.image
    @surface.blit portrait, [LEFT-60,TOP]

    font = FreeVikings::FONTS['default']
    h = font.height sentence, TEXT_WIDTH
    if h < portrait.h then
      h = portrait.h
    end
    box = RUDL::Surface.new [TEXT_WIDTH, h]
    box.fill speaker.class::FAVOURITE_COLOUR
    font.render box, TEXT_WIDTH, sentence

    @surface.blit box, [LEFT, TOP]
  end
end

class GiacommoProgrammer
  FAVOURITE_COLOUR = [100,100,100]
  def initialize
    @portrait = Image.load 'handy2.tga'
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

  talk.to_storyframes.each {|f| 
    s << f
  }

  s << Story::TextFrame.new("But soon the phone was ringing again.")

  talk2.to_storyframes.each {|f| 
    s << f
  }
end

LOCATION.story = story
