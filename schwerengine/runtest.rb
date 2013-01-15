#!/usr/bin/ruby

# runtest.rb
# Executes unit tests stored in direstory 'tests'.

$:.push File.expand_path('.')
$:.push File.expand_path('tests')
Dir.chdir 'tests'
require 'test.rb'
