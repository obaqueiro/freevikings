#!/usr/bin/ruby
# igneus 6.3.2005

# Skript pro spousteni testu, ktere jsou v oddelenem adresari.

$:.push File.expand_path('.')
Dir.chdir 'tests'
require 'test.rb'
