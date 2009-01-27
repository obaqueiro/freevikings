#!/usr/bin/ruby -w

# makerelease.rb
# igneus 30.8.2008

# Tool automating release
# Must be executed in freeVikings CVS working directory!
# (Don't be afraid, it won't do anything bad with it. All work is
# being done in a temporary directory under /tmp)

require 'highline'

CVS_ARGS = "-z3 -d:ext:igneus_cz@freevikings.cvs.sourceforge.net/cvsroot/freevikings"
# CVS_ARGS = "-z3 -d:pserver:anonymous@freevikings.cvs.sourceforge.net/cvsroot/freevikings"

# Most of the methods of this module are tasks of release process
module Tasks

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
           # :ftp, # - ftp archive to web
           :freshmeat, :raa, # - update freshmeat and RAA entries
           :cleanup # - delete tmp dir
          ]

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
      do_cvs "checkout -P -r "+branch_name(mod)+" "+mod
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

    system "mv gameui freeVikings-#{$setup.dir_version}/lib"
    system "mv schwerengine freeVikings-#{$setup.dir_version}/lib"

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

  # freshmeat.net: release focus
  RELEASE_FOCUS_CODES = ["N/A",
                         "Initial freshmeat announcement",
                         "Documentation",
                         "Code cleanup",
                         "Minor feature enhancements",
                         "Major feature enhancements",
                         "Minor bugfixes",
                         "Major bugfixes",
                         "Minor security fixes",
                         "Major security fixes"]

  # freshmeat.net XMLRPC interface: error codes
  XMLRPC_ERRORCODES = {10 => "Login incorrect", 
    20 => 'Session inconsistency',
    21 => 'Session invalid', 30 => 'Branch ID incorrect',
    40 => 'Permission to publish release denied',
    50 => 'Version string missing', 51 => 'Duplicate version string',
    60 => 'Changes field empty', 61 => 'Changes field too long',
    62 => 'Changes field contains HTML', 70 => 'No valid email address set',
    80 => 'Release not found', 81 => 'Project not found',
    90 => 'Release focus missing', 91 => 'Release focus invalid',
    100 => 'License invalid', 999 => 'Unknown error'}

  SF_GROUP_ID = 198410
  SF_PACKAGE_ID = 235081 # id of package 'freevikings'
     
  def freshmeat # - update freshmeat entry using freshmeat XML-RPC API
    require 'uri'
    require 'xmlrpc/client'

    Dir.chdir $setup.tmpdir

    print "Edit changes: "
    if ! File.exist? 'FRSHCHANGES' then
      system "cp freeVikings-#{$setup.dir_version}/RELEASE ./FRSHCHANGES"
      system "#{ENV['EDITOR']} FRSHCHANGES"
      puts "changes file found; skipping"
    else
      puts "yes"
    end

    changes_text = ""
    File.open('FRSHCHANGES') {|f|
      f.each {|l| changes_text += " "+l.chomp}
    }

    puts "freshmeat: login"

    # This trick with URI is from Freshmeat-Ruby by pabs:
    # http://unix.freshmeat.net/projects/freshmeat-ruby/
    # (I don't know exactly what it does, but it works,
    # while when I had 
    # session = XMLRPC::Client.new('http://freshmeat.net/xmlrpc/', '/RPC2', 80)
    # it didn't...)
    uri = URI::parse "http://freshmeat.net/xmlrpc"
    session = XMLRPC::Client.new(uri.host, uri.request_uri, uri.port)

    print "Give freshmeat.net password: "
    password = STDIN.gets.chomp

    loginpack = session.call("login", {'username' => 'igneus', 'password' => password})
    puts loginpack
    sid = loginpack['SID']
    if loginpack['API Version'] != '1.03' then
      raise "New API version - update!"
    end

    puts "freshmeat: submit release"

    arguments = {
      'SID' => sid,
      'project_name' => 'freeVikings',
      'branch_name' => 'Default',
      'version' => $setup.version,
      'changes' => changes_text,
      'release_focus' => $setup.release_focus,
      'url_tgz' => 'http://downloads.sourceforge.net/freevikings/freeVikings-'+$setup.dir_version+".tar.gz"
      # 'url_tgz' => 'http://freevikings.wz.cz/packages/'+$setup.ftp_dir_version+'/freeVikings-'+$setup.dir_version+".tar.gz"
    }
    p arguments
    puts session.call("publish_release", arguments)

    puts "freshmeat: logout"

    puts session.call("logout", sid)
  end

  def raa # - update RAA entry
    Dir.chdir $setup.tmpdir

    # I haven't found any working remote-procedure-call interface for RAA
    # updates, so I'll have to hack the web interface...

    require 'net/http'
    require 'uri'
    require 'hpricot' # Why's HTML parsing library

    # retrieve page with update form
    uri = URI::parse 'http://raa.ruby-lang.org/update.rhtml?name=freevikings'
    page = Net::HTTP.get uri

    # get form data from it
    doc = Hpricot(page)
    form = (doc / "form").find {|f| f['action'] =~ /regist.rhtml/} # find the right form (there's another one for searching)

    postdata = {}

    inputs = form / "input"
    inputs.each do |inp|
      if ['submit', 'reset', 'password'].member? inp['type'] then
        # useless inputs
        next
      elsif ! ['text','checkbox','hidden'].member? inp['type'] then
        raise "Unsupported input type '#{inp['type']}'"
      else
        postdata[inp['name']] = inp['value']
      end
    end

    selects = form / "select"
    selects.each do |sel|
      value = ''
      others = []
      (sel / "option").each do |opt|
        if opt.has_attribute? "selected" then
          value = opt['value']
        end
      end
      if value == '' then
        puts "Select "+sel['name']+" has no default value - which to choose?"
        others.each_with_index {|o,i| puts "#{i}: #{o}"}
        i = gets.chom.to_i
        value = others[i]
      end
      postdata[sel['name']] = value
    end

    textareas = form / "textarea"
    textareas.each do |txt|
      postdata[txt['name']] = txt.inner_html
    end

    # change what is needed

    print "Type RAA password: "
    password = gets.chomp

    postdata['pass'] = password

    postdata['minoredit'] = 'off'
    postdata['version'] = $setup.version
    postdata['download'] = 'http://downloads.sourceforge.net/freevikings/freeVikings-'+$setup.dir_version+".tar.gz"
    # postdata['download'] = 'http://freevikings.wz.cz/packages/'+$setup.ftp_dir_version+'/freeVikings-'+$setup.dir_version+".tar.gz"

    # POST updated data to the server
    puts Net::HTTP.post_form(URI::parse('http://raa.ruby-lang.org/regist.rhtml'),
                             postdata)
  end

  def cleanup
    puts "Removing directory "+$setup.tmpdir
    Dir.rmdir $setup.tmpdir
  end

  private

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
end

# MAIN ===================================================================

require 'optparse'
require 'ostruct'

INTERACTIVE_MODE = 0
QUICK_MODE = 1
ONE_STEP_MODE = 2


### set default setup

$setup = OpenStruct.new
$setup.step = 1
$setup.pretend = false # useless
$setup.working_directory = Dir.pwd
$setup.modules = ['freeVikings', 'gameui', 'schwerengine']
$setup.release_focus = 4 # Minor feature enhancements
$setup.mode = INTERACTIVE_MODE

### parse commandline options

parser = OptionParser.new(ARGV) do |opts|
  opts.separator "Options giving information about the release"
  opts.separator ""

  opts.on('-v', '--version VERSION',
          "Version number/tag, e.g. '1.15' or '1.16pre7'") do |v|
    $setup.version = v
    $setup.cvs_version = $setup.version.gsub(/[\s.]/, "-")
    $setup.dir_version = $setup.version.gsub(/\s/, '-')
    $setup.ftp_dir_version = $setup.version.sub(/\s/, "_")
    $setup.tmpdir = '/tmp/fvrelease--'+$setup.ftp_dir_version+'-tmpdir'    
  end

  opts.on('-f', '--release-focus FOCUS', Integer,
          "Set release focus for freshmeat.net; default: #{$setup.release_focus}") do |f|
    $setup.release_focus = f
  end

  opts.separator ""
  opts.separator "Options for choosing of subset of tasks to be done"
  opts.separator ""

  opts.on('-s', '--step STEP', Integer,
          "Step (task) to start with") do |s|
    $setup.step = s
  end

  opts.on('-o', '--only-step STEP', Integer,
          "Do just one step (task)") do |s|
    $setup.step = s
    $setup.mode = ONE_STEP_MODE
  end

  opts.separator ""
  opts.separator "Other options"
  opts.separator ""

  opts.on('-h', '--help',
          "Print this help and exit") do
    puts opts
    puts
    puts "Step numbers:"
    puts
    Tasks::STEPS.each_with_index {|s,i| puts "    #{i}: #{s}"}
    puts
    puts "Release focus codes"
    puts
    Tasks::RELEASE_FOCUS_CODES.each_with_index {|c,i| puts "    #{i}: #{c}"}  
    exit    
  end
end
parser.parse!

### check if compulsory arguments have been set
if $setup.version.nil? then
  raise "Version tag/number is a mandatory commandline argument."
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

### start highline (I don't know how to better call the object...):

$highline = HighLine.new

### run tasks

include Tasks

case $setup.mode

when INTERACTIVE_MODE

  $setup.step.upto(STEPS.size-1) do |step|
    begin
      puts
      puts "#{step}. step: #{STEPS[step]}"
      puts
      $highline.say "Continue?\n"
      case $highline.choose("continue", "skip", "exit")
      when "skip"
        next
      when "exit"
        exit
      end
      
      # call step method:
      send(STEPS[step])
    rescue
      STDERR.puts "ERROR in step #{step}, #{STEPS[step]}. Please, fix this error and consider running this step again."
      raise
    end  
  end

when ONE_STEP_MODE

  if $setup.mode == ONE_STEP_MODE then
    puts "#{$setup.step}. step: #{STEPS[$setup.step]}"
  send(STEPS[$setup.only_step])
  exit

end

when QUICK_MODE

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

end

