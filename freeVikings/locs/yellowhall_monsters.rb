# yellowhall_monsters.rb
# igneus 9.6.2005
# Lokacni skript pridavajici potvory do lokace Yellow Hall

require 'slug.rb'
require 'plasmashooter.rb'
require 'switch.rb'
require 'robot.rb'
require 'bridge.rb'
require 'apple.rb'

require 'imagebank.rb'

include FreeVikings

# A PlasmaShooter
shooter = FreeVikings::PlasmaShooter.new [730, 430]

shooter.instance_eval do
  @image = Image.new 'yellow_map/yellow_spitter.tga'
end

# Images which are used in this location for switches instead of
# the default look
switch_images = {
  'true' => Image.new('yellow_map/switch_on.tga'),
  'false' => Image.new('yellow_map/switch_off.tga')
}

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
switch_1 = FreeVikings::Switch.new([520,410], true, switch_1_action, switch_images)

# A bridge
Y_VALUES = [260, 480]
bridge = FreeVikings::FallingBridge.new 600, *Y_VALUES

# An action for switch_2
switch_2_action = Proc.new do |switch_state|
  bridge.next
end

# A switch which controlls the Bridge's activity.
switch_2 = FreeVikings::Switch.new([120, 280], true, switch_2_action, switch_images)



LOCATION.add_sprite shooter
LOCATION.add_active_object switch_1
LOCATION.add_sprite FreeVikings::Robot.new([800, 400], 120)
LOCATION.add_sprite bridge

LOCATION.add_active_object switch_2

LOCATION.add_item Apple.new([400,80])
