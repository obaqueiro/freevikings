#!/usr/bin/ruby

# level_info_tool.rb
# igneus 7.8.2008

dir = ARGV.shift

if ! dir then
  puts
  puts "$ ruby levelinfotool.rb DIR"
  puts
  puts "DIR is a directory with Level or LevelSuite; this tool reads it and prints to stdout info about all included levels"
  exit 1
end

require 'fvdef.rb'
require 'schwerengine/schwerengine.rb'
SchwerEngine.init(SchwerEngine::DISABLE_LOG4R_SETUP)
include SchwerEngine
SchwerEngine.config = FreeVikings

require 'log4r'
require 'log4rsetupload'

require 'levelsuite.rb'

module FreeVikings
  class LevelSuite
    def each
      @members.each {|m| yield m}
    end

    def output(indent)
      puts
      print " " * (indent*2)
      puts "S: #{@title}   [#{@dirname}]"

      each {|m| m.output(indent+1)}
    end
  end

  class Level
    def output(indent)
      puts
      gap = " " * (indent*2)
      puts gap + "L: #{@title}"
      gap = gap + "  "
      puts gap + "password:  #{password}"
      puts gap + "directory: #{@dirname}"
    end
  end
end

FreeVikings::LevelSuite.new(dir).output(0)


