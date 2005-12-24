# testlocationloader.rb
# igneus 24.12.2005

require 'locationloader.rb'

class TestLocationLoader < Test::Unit::TestCase

  include FreeVikings

DATA = <<EOT
<?xml version="1.0" ?>

<location>
  <info>
    <title>Arctic Tutorial</title>
    <author>Jakub Pavlik</author>
  </info>

  <body>
    <password>ATUT</password>
    <map src="arctictut_loc.xml"/>
    <script src="arctictut_script.rb"/>
    <start horiz="80" vertic="300"/>
    <exit horiz="2080" vertic="320"/>
  </body>
</location>
EOT

  def setup
    @loader = LocationLoader.new(DATA)
  end

  def testInfo
    assert_equal "Arctic Tutorial", @loader.title, "Loader must publish location name."
    assert_equal "Jakub Pavlik", @loader.author
    assert_equal "ATUT", @loader.password
    assert_equal [80,300], @loader.start
    assert_equal [2080,320], @loader.exit
  end
end
