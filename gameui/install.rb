#!/usr/bin/ruby

# install.rb
# igneus 6.12.2005
# GameUI installer.

print <<EOS
install.rb

This is GameUI installer. It is going to install GameUI on your system.
Do you want to proceed? [yes or no]
EOS

case gets
when /^[Yy][Ee][Ss]/
  # go on.
else
  puts
  puts "So you don't want to..."
  exit
end

# looks at the name of file and says if the file should be installed.
# (Checks suffix.)
def installed_file?(fn)
  fn =~ /\.ttf$/ or fn =~ /\.rb$/
end

DirsToInstall = ['menu',
                 'menu/items',
                 'textrenderer',
                 'textrenderer/fonts']

require 'rbconfig'
require 'ftools'

sitelibdir = Config::CONFIG['sitelibdir']
dest_dir = sitelibdir + '/gameui'

# install gameui.rb
File.install 'gameui.rb', sitelibdir+'/gameui.rb', nil, true

# install all the other files
DirsToInstall.each do |d|
  dest_subdir = dest_dir + '/' + d

  File.mkpath(dest_subdir, true)

  Dir.open(d) do |dir|
    dir.each do |f|
      if installed_file? f then
        File.install(d + '/' + f, dest_subdir + '/' + f, nil, true)
      elsif File.directory? d+'/'+f
      else
        STDERR.puts "OMITTING " + d + '/' + f
      end
    end
  end
end
