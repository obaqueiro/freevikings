Gem::Specification.new do |s|
  s.name        = 'schwerengine'
  s.version     = '0.0.0'
  # s.date        = ''
  s.summary     = '2D game engine'

  s.authors     = ['Jakub Pavlík']
  s.email       = 'jkb.pavlik@gmail.com'
  s.files       = %w(lib/**/*.rb tests/*.rb)
                  .collect {|glob| Dir[glob] }
                  .flatten
                  .reject {|path| path.end_with? '~' } # Emacs backups
  s.homepage    = 'http://freevikings.wz.cz'
  s.licenses    = ['LGPL-2.0']

  s.add_dependency 'log4r'
  s.add_dependency 'gosu'
end
