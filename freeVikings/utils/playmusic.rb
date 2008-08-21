#!/usr/bin/ruby -w

# playmusic.rb
# igneus 21.8.2008

# I haven't got any piece of software for playing MOD files,
# but I know it is possible to play them using SDL and while I am going
# to add sounds support to freeVikings, I find it useful to write a small
# "MOD-player" first - it is a good way to learn to use the sounds-related
# part of RUDL interface.

if ARGV.size == 0 then
  puts "Usage:\n\nplaymusic.rb MUSICFILE"
  exit
end

music_file = ARGV.shift

require 'RUDL'
include RUDL

music = Music.new music_file
music.play

loop do
  EventQueue.get.each do |e|
  end

  if ! music.busy? then
    exit
  end

  sleep 0.5
end
