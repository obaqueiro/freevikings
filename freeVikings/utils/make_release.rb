#!/usr/bin/ruby -w

# makerelease.rb
# igneus 30.8.2008

# Tool automating release
# Must be executed in freeVikings CVS working directory!

CVS_ARGS = "-z3 -d:ext:igneus_cz@freevikings.cvs.sourceforge.net/cvsroot/freevikings"

# Tasks:
STEPS = [nil,
         :make_branch, # - CVS: make branch
         :create_directory, # - create directory in /tmp and chdir there
         :checkout_new_branch, # - CVS: checkout new branch
         :readme, # - modify README
         :release, # - create RELEASE
         :commit, # - CVS: commit
         :remove_sandbox, # - remove the CVS working directory
         :export, # - CVS: export
         :rename, # - rename directory freeVikings to freeVikings-VERSION
         :archives, # - create archive
         :ftp, # - ftp archive to web
         :freshmeat, :raa, # - update freshmeat and RAA entries
         :cleanup # - delete tmp dir
        ]

# Most of the methods of this module are tasks of release process
module Tasks

  # not a task, helpful tool.
  # runs or puts CVS command.
  def do_cvs(command)
    command = "cvs "+CVS_ARGS+" "+command
    unless $setup.pretend
      system command
    else
      puts command
    end
  end

  def make_branch # - CVS: make branch
    ['../freeVikings', '../gameui', '../schwerengine'].each do |d|
      Dir.chdir d
      puts "directory "+Dir.pwd
      branch_name = branch_name(File.basename(Dir.pwd))
      puts "creating branch "+branch_name
      do_cvs "tag -b "+branch_name
    end

    Dir.chdir $setup.working_directory
  end

  # Not a task, but helpful method.
  # gets module name (freeVikings, gameui, schwerengine) and returns
  # CVS branch name
  def branch_name(mod)
    mod.downcase+"-"+(mod == 'freeVikings' ? '' : 'fv-')+$setup.cvs_version
  end

  def create_directory # - create directory in /tmp
    puts "Creating directory "+$setup.tmpdir
    Dir.mkdir $setup.tmpdir
  end

  # Normally we don't need to check out everything - just the files we will
  # modify. On the other side, sometimes you run the release creation process
  # step by step and want to do something manually.
  # An option should be added to select: checkout everything or not?

  def checkout_new_branch # - CVS: checkout new branch
    Dir.chdir $setup.tmpdir
    $setup.modules.each do |mod|
      puts "Checking out module #{mod}, branch #{branch_name(mod)}"
      do_cvs "checkout -r "+branch_name(mod)+" "+mod
    end
  end

  def readme # - modify README
    # add version tag and date:
    Dir.chdir $setup.tmpdir+'/freeVikings'
    a = []
    File.open('README', 'r') do |f|
      f.each {|l| a << l}
    end
    a[1].gsub!(/X+/) {|match| $setup.version.ljust(match.size)}
    a[1].gsub!(/D+/) {|match| Time.now.strftime('%m/%d/%Y').ljust(match.size)}

    unless $setup.pretend
      File.open('README', 'w') do |f|
        a.each {|l| f.puts l}
      end
    else
      puts "README[1]: " + a[1]
    end
  end
     
  def release # - create RELEASE
    Dir.chdir $setup.tmpdir+'/freeVikings'
    File.open('RELEASE', 'w') do |fw|
      fw.puts $setup.version
      fw.puts Time.now.strftime('%m/%d/%Y')
      File.open('CHANGELOG', 'r') do |fr|
        # Add changes since the last release
        while !((l = fr.gets) =~ /\[release/) do
          if !(l =~ /^\[/) and !(l =~ /^\s*$/) then
            fw.puts l
          end
        end
      end
    end

    # open file in editor for the release-maker to modify it
    system "#{ENV['EDITOR']} RELEASE"

    do_cvs "add RELEASE"    
  end
     
  def commit # - CVS: commit
    Dir.chdir $setup.tmpdir+'/freeVikings'

    do_cvs "commit"
  end
     
  def remove_sandbox # - remove the CVS working directory
    Dir.chdir $setup.tmpdir
    $setup.modules.each do |d|
      system "rm -rf #{d}"
    end
  end

  def export # - CVS: export
    Dir.chdir $setup.tmpdir
    $setup.modules.each do |mod|
      do_cvs "export -r #{branch_name(mod)} #{mod}"
    end
  end

  def rename # - rename directory freeVikings to freeVikings-VERSION
    Dir.chdir $setup.tmpdir
    system "mv freeVikings freeVikings-"+$setup.dir_version
  end
     
  def archives # - create archives
    Dir.chdir $setup.tmpdir
    Dir['*'].each do |d|
      if mod = $setup.modules.find {|m| d =~ Regexp.new(m)} then
        print "packing module '#{mod}', directory #{d}"
        archive_name = mod+"-"+(mod == 'freeVikings' ? '' : 'fv-')+$setup.dir_version+".tar.gz"
        system "tar -c #{d} | gzip > #{archive_name}"
        puts " > archive "+archive_name
      end
    end
  end
     
  def ftp # - ftp archives to web
    Dir.chdir $setup.tmpdir
    
    print 'Give password for freevikings.wz.cz@freevikings.wz.cz: '
    password = gets.chomp
    
    yafc_invocation = "yafc -m none freevikings.wz.cz:#{password}@freevikings.wz.cz"
    yafc_commands = "cd packages\n"+"mkdir #{$setup.ftp_dir_version}\n"+"cd #{$setup.ftp_dir_version}\n"+"put -f freeVikings-#{$setup.dir_version}/RELEASE\n"
    Dir['*.tar.gz'].each {|f| yafc_commands += "put -f #{f}\n"}
    # Well, it's a shame, but I'm not familiar with pipes in ruby,
    # so stdin for yafc will be written to a file and the file than
    # given to yafc using cat...
    File.open("yafccommands", 'w') {|f| f.puts yafc_commands}
    system "cat yafccommands | #{yafc_invocation}"
  end
     
  def freshmeat # - update freshmeat entry using freshmeat XML-RPC API
    require 'xmlrpc/client'

    error_codes = {10 => "Login incorrect", 20 => 'Session inconsistency',
      21 => 'Session invalid', 30 => 'Branch ID incorrect',
      40 => 'Permission to publish release denied',
      50 => 'Version string missing', 51 => 'Duplicate version string',
      60 => 'Changes field empty', 61 => 'Changes field too long',
      62 => 'Changes field contains HTML', 70 => 'No valid email address set',
      80 => 'Release not found', 81 => 'Project not found',
      90 => 'Release focus missing', 91 => 'Release focus invalid',
      100 => 'License invalid', 999 => 'Unknown error'}

    Dir.chdir $setup.tmpdir

    if ! File.exist? 'FRSHCHANGES' then
      system "cp freeVikings-#{$setup.dir_version}/RELEASE ./FRSHCHANGES"
      system "#{ENV['EDITOR']} FRSHCHANGES"
    end

    changes_text = ""
    File.open('FRSHCHANGES') {|f|
      f.each {|l| changes_text += " "+l.chomp}
    }

    session = XMLRPC::Client.new "http://freshmeat.net/xmlrpc/"

    print "Give freshmeat.net password: "
    password = gets.chomp

    loginpack = session.call("login", {'username' => 'igneus', 'password' => password})
    puts loginpack
    sid = loginpack['SID']
    if loginpack['API Version'] != '1.02' then
      raise "New API version - update!"
    end

    puts session.call("publish_release", {
                   'SID' => sid,
                   'project_name' => freeVikings,
                   'branch_name' => 'Default',
                   'version' => $setup.version,
                   'changes' => changes_text,
                   'release_focus' => $setup.release_focus,
                   'url_tgz' => 'http://freevikings.wz.cz/packages/'+$setup.ftp_dir_version+'/freeVikings-'+$setup.dir_version+".tar.gz"
                 })

    puts session.call("logout", sid)
  end

  def raa # - update RAA entry
    Dir.chdir $setup.tmpdir+'/freeVikings'
    raise "not implemented" 
  end

  def cleanup
    Dir.chdir $setup.tmpdir+'/freeVikings'
    puts "Removing directory "+$setup.tmpdir
    Dir.rmdir $setup.tmpdir
  end
end

# MAIN ===================================================================

require 'getoptlong'
require 'ostruct'

### get setup

$setup = OpenStruct.new
$setup.step = 1
$setup.pretend = false
$setup.working_directory = Dir.pwd
$setup.only_step = nil
$setup.modules = ['freeVikings', 'gameui', 'schwerengine']
$setup.release_focus = 4 # Minor feature enhancements

options = GetoptLong.new(['--version', '-v', GetoptLong::REQUIRED_ARGUMENT], # release version number
                         ['--pretend', '-p', GetoptLong::NO_ARGUMENT], # do not execute the commands, just write them out
                         ['--step', '-s', GetoptLong::REQUIRED_ARGUMENT], # start with some step (work has been started before)
                         ['--only-step', '-o', GetoptLong::REQUIRED_ARGUMENT], # do just one step
                         ['--release-focus', '-f', GetoptLong::REQUIRED_ARGUMENT]) # freshmeat.net code for release focus:
# 0 - N/A
# 1 - Initial freshmeat announcement
# 2 - Documentation
# 3 - Code cleanup
# 4 - Minor feature enhancements
# 5 - Major feature enhancements
# 6 - Minor bugfixes
# 7 - Major bugfixes
# 8 - Minor security fixes
# 9 - Major security fixes


options.each do |option, argument|
  case option
  when "--version"
    $setup.version = argument
    $setup.cvs_version = $setup.version.gsub(/[\s.]/, "-")
    $setup.dir_version = $setup.version.gsub(/\s/, '-')
    $setup.ftp_dir_version = $setup.version.sub(/\s/, "_")
    $setup.tmpdir = '/tmp/fvrelease--'+$setup.ftp_dir_version+'-tmpdir'
  when "--pretend"
    $setup.pretend = true
  when "--step"
    $setup.step = argument.to_i
  when "--only-step"
    $setup.only_step = argument.to_i
  when "--release-focus"
    $setup.release_focus = argument
  end
end

if $setup.version.nil? then
  STDERR.puts "Give version tag, please."
  exit 1
end

### check if we are in the freeVikings working directory and have also
# gameui and schwerengine:
if File.basename(Dir.pwd) != 'freeVikings' ||
    Dir['CVS'].empty? then
  STDERR.puts "Not in freeVikings working directory."
  exit 1
end

if Dir['../gameui/CVS'].empty? then
  STDERR.puts "We haven't gameui working directory."
  exit 1
end

if Dir['../schwerengine/CVS'].empty? then
  STDERR.puts "We haven't schwerengine working directory."
  exit 1
end

include Tasks

### do just one step?

if $setup.only_step then
  puts "#{$setup.only_step}. step: #{STEPS[$setup.only_step]}"
  send(STEPS[$setup.only_step])
  exit
end

### do step by step

$setup.step.upto(STEPS.size-1) do |step|
  begin
    puts "#{step}. step: #{STEPS[step]}"
    # call step method:
    send(STEPS[step])
  rescue
    STDERR.puts "ERROR in step #{step}, #{STEPS[step]}"
    raise
  end  
end
