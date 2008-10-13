#!/usr/bin/ruby

# runtest.rb
# Skript pro spousteni testu, ktere jsou v oddelenem adresari.

# nahrajeme nastaveni log4r (to je pouzivano v nekterych z testovanych trid)
require 'log4r'
require 'log4rsetupload.rb'

$:.push File.expand_path('.')
$:.push File.expand_path('tests')
$:.push File.expand_path('lib')

Dir.chdir 'tests'
require 'test.rb'
