#!/bin/env ruby

# licencise.rb
# igneus 19.5.2005

# Adds the license notice to the beginning of all
# the files listed as arguments.

require 'getoptlong'

opts = GetoptLong.new(
["--prepend", "-p", GetoptLong::REQUIRED_ARGUMENT]
)

$prepended = "# No license notice."

opts.each do |option, argument|
  case option
  when "--prepend"
    $prepended = File.open(argument).to_a.join('\n')
  end
end

ARGV.each do |processed_file|
  fr = File.open processed_file
  data_unprocessed = fr.to_a
  fr.close

  data = []
  while d = data_unprocessed.shift do
    break unless (d =~ /^#/) or (d =~ /^\s*$/)
    data.push d
  end
  data.push $prepended
  data.concat data_unprocessed

  fw = File.open processed_file, "w"
  data.each {|d| fw.puts d}
  fw.close
end
