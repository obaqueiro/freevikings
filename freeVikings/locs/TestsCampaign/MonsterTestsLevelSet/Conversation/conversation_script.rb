require 'talk'

vikings = LOCATION.team

# Set up a simple conversation at the beginning of level.
talk = Talk.new(File.open('locs/TestsCampaign/MonsterTestsLevelSet/Conversation/conversation.yaml'))
talk.start(vikings[0], vikings[1], vikings[2])
LOCATION.talk = talk
