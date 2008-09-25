# yellowhall_monsters.rb
# igneus 9.6.2005
# Lokacni skript pridavajici potvory do lokace Yellow Hall

require 'monsters/plasmashooter.rb'
require 'monsters/robot.rb'
require 'monsters/lift.rb'
require 'switch.rb'
require 'apple.rb'
require 'story.rb'
require 'talk.rb'

include FreeVikings

# A PlasmaShooter
shooter = FreeVikings::PlasmaShooter.new [730, 430]

shooter.instance_eval do
  @image = Image.load 'themes/NuclearTheme/yellow_spitter.tga'
end

# A Proc called when the state of switch_1 is changed
switch_1_action = Proc.new do |switch_state| 
  if switch_state then
    shooter.on
  else
    shooter.off
  end
  # puts shooter.firing?.to_s
end

# A switcher which controlls the PlasmaShooter
switch_1 = FreeVikings::Switch.new([520,410], LOCATION.theme, true, switch_1_action)

# A bridge
Y_VALUES = [260, 481]
bridge = FreeVikings::Lift.new(600, Y_VALUES, LOCATION.theme)

# An action for switch_2
switch_2_action = Proc.new do |switch_state|
  bridge.next
end

# A switch which controlls the Bridge's activity.
switch_2 = FreeVikings::Switch.new([120, 280], LOCATION.theme, true, switch_2_action)



LOCATION.add_sprite shooter
LOCATION.add_active_object switch_1
LOCATION.add_sprite FreeVikings::Robot.new([800, 400], 120)
LOCATION << bridge

LOCATION.add_active_object switch_2

LOCATION.add_item Apple.new([400,80])

# Set up Story for the end of world:
end_story = Story.new do |s|
  ## This is traditional end-of-world text. I can't simply delete it, it's
  ## really ancient, but it should be replaced be some more truthful one...
  ##
  #   Erik, Baleog and Olaf have forgotten Tomator.
  #   They were just walking, clobbering monsters and
  #   exploring foreign sides.
  #   Suddenly something like a thunder sounded and they
  #   all fainted. Where did they wake up?
  #   Don't forget to download the next version of freeVikings!
  #   |
  #   http://freevikings.wz.cz
  #   |
  #   All comments, bug reports, ideas etc. are appreciated.
  #   |
  #   severus@post.cz

  talk = Talk.new(File.open('locs/DefaultCampaign/NuclearLabsLevelSet/YellowHall/end_of_world_talk.yaml'))
  team = LOCATION.team
  talk.start(team['Erik'], team['Baleog'], team['Olaf'])
  Story::TalkFrame.talk_to_frames(talk).each {|f| s << f}

  s << Story::TextFrame.new("Yes, you successfully reached end of this campaign.\n\nCongratulations!")
end

LOCATION.on_exit = Proc.new { LOCATION.story = end_story }
