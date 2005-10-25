#!/usr/bin/ruby

# install.rb
# igneus 24.10.2005

# Installation script for freeVikings.

require 'optparse'
require 'ftools'

# Store configuration:
module FvInstaller
  CONFIG = {'prefix' => '/usr/local',
            'mode' => 'install'}

  begin
    File.open('RELEASE') {|fr| CONFIG['version'] = fr.gets.chomp.strip}
  rescue Errno::ENOENT => ex
    puts ex.message
    CONFIG['version'] = 'development-snapshot'
  end
end

# An instance of this class works out installation of files 
# from one directory to another.
class Installer
  def initialize(src_dir, dest_dir, verbose=false)
    @src_dir = src_dir
    @dest_dir = dest_dir
    @verbose = verbose
    yield self if block_given?
  end

  # installs file or directory
  def install(fd, mode=nil)
    if File.directory? fd then
      File.mkpath(@dest_dir+'/'+fd, @verbose)
    end

    if File.file? fd then
      File.install(@src_dir+'/'+fd, @dest_dir, mode, @verbose)
    end
  end

  def Installer.recursive_install(src_dir, dest_dir)
    inst = Installer.new(src_dir, dest_dir)
    Dir.new(src_dir).each do |file|
      next if file == '.' or file == '..'

      if File.directory? file then
        subdir_name = dest_dir + '/' + file
        File.mkpath subdir_name
        Installer.recursive_install(src_dir+'/'+file, subdir_name)
      else
        inst.install file
      end
    end
  end
end

# Parse options:
options = OptionParser.new do |opts|
  opts.banner = "Usage: install.rb [options]"
  
  opts.on('-i', '--install', 'Install freeVikings') do |mode|
    FvInstaller::CONFIG['mode'] = 'install'
  end

  opts.on('-u', '--uninstall', 'Uninstall freeVikings') do |mode|
    FvInstaller::CONFIG['mode'] = 'uninstall'
  end

  opts.on('-p', '--prefix=prefix', "Base directory for installation (#{FvInstaller::CONFIG['prefix']} by default)") do |prefix|
    FvInstaller::CONFIG['prefix'] = prefix
  end

  opts.on('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
end
options.parse!

if FvInstaller::CONFIG['mode'] == 'install'

  prefix = FvInstaller::CONFIG['prefix']
  data_dir = prefix + "/share/freeVikings-#{FvInstaller::CONFIG['version']}"
  bin_dir = prefix + '/bin'
  executable_name = 'freevikings'

  puts "Creating executable"
  File.open(executable_name, 'w') do |fw|
    fw.puts '#!/bin/bash'
    fw.puts 'cd ' + data_dir
    fw.puts 'ruby freevikings.rb'
  end
  `chmod 555 freevikings`

  puts "Installing freeVikings in prefix #{prefix}:"

  puts "Installing executable in #{bin_dir}"
  Installer.new(Dir.pwd, bin_dir, true).install executable_name, 0555

  puts "Installing data in #{data_dir}"
  File.mkpath(data_dir)
  Installer.recursive_install(Dir.pwd, data_dir)

elsif FvInstaller::CONFIG['mode'] == 'uninstall'

end
