# penguin_script.rb
# igneus 22.10.2005

# Script of the testing location for monster class Penguin

load 'penguin.rb'

penguin = Penguin.new [300, 11*40-Penguin::HEIGHT]
LOCATION << penguin
