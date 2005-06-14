# yellowhall_monsters.rb
# igneus 9.6.2005
# Lokacni skript pridavajici potvory do lokace Yellow Hall

require 'slug.rb'
require 'plasmashooter.rb'
require 'switch.rb'
require 'robot.rb'

require 'imagebank.rb'

include FreeVikings

MONSTERS = Array.new

#MONSTERS.push FreeVikings::Slug.new([500,440])
shooter = FreeVikings::PlasmaShooter.new [700, 430]

shooter.instance_eval do
  @image = Image.new 'yellow_map/yellow_spitter.tga'
end

switch_images = {
  'true' => Image.new('yellow_map/switch_on.tga'),
  'false' => Image.new('yellow_map/switch_off.tga')
}

switch_action = Proc.new do |switch_state| 
  if switch_state then
    shooter.on
  else
    shooter.off
  end
  # puts shooter.firing?.to_s
end
switch = FreeVikings::Switch.new([580, 410], true, switch_action, switch_images)

MONSTERS.push shooter
MONSTERS.push switch
MONSTERS.push FreeVikings::Robot.new([800, 400], 120)