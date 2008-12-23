#!/usr/bin/ruby

# runtest.rb
# Script for running tests

# load Log4r setup
require 'log4r'
require 'log4rsetupload.rb'

# add loading paths
$:.push File.expand_path('.')
$:.push File.expand_path('tests')
$:.push File.expand_path('lib')
$:.push File.expand_path('entities')

# run tests
Dir.chdir 'tests'
require 'test.rb'
