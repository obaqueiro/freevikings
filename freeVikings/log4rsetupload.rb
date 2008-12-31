# log4rsetupload.rb
# igneus 30.5.2005

# Nahrani konfigurace Log4r.
# Obsah tohoto souboru jsem vyjmul, protoze uz by byl opsany ve trech
# souborech (freevikings.rb tests/test.rb utils/locview.rb)
# a kazdy programator vi, ze duplikace s sebou vzdycky nosi plny pytel 
# neprijemnosti.

require 'log4r/configurator'
Log4r::Configurator.load_xml_file('config/log4rconfig.xml')
Log4r::Logger.global.level = Log4r::OFF
