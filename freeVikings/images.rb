# images.rb
# igneus 26.11.2005

# === Graphic data classes ===

# Until today all the classes working with graphic data had been
# defined in one file called 'imagebank.rb'. But it was incomfortable
# to search for anything in such a huge heap of text so I divided
# this big file into smaller ones. This file is provided to enable
# you to load all the gfx stuff in one require clause.

require 'image.rb'
require 'animation.rb'
require 'portrait.rb'
require 'model.rb'
