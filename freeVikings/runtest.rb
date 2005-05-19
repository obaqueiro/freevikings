#!/usr/bin/ruby

# runtest.rb
# Skript pro spousteni testu, ktere jsou v oddelenem adresari.

$:.push File.expand_path('.')
$:.push File.expand_path('tests')
Dir.chdir 'tests'
require 'test.rb'
