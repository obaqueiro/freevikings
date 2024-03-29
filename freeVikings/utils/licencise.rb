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
$empty_line = "\n"

opts.each do |option, argument|
  case option
  when "--prepend"
    $prepended = File.open(argument).to_a.join()
  end
end

ARGV.each do |processed_file|
  puts processed_file

  fr = File.open processed_file
  data_unprocessed = fr.to_a
  fr.close

  data = []
  while d = data_unprocessed.shift do
    break unless (d =~ /^#!/)
    data.push d
  end
  data_unprocessed.unshift d

  data.push $empty_line if data.size > 0
  data.push $prepended
  data.push $empty_line

  data.concat data_unprocessed

  fw = File.open processed_file, "w"
  data.each {|d| fw.puts d}
  fw.close
end
