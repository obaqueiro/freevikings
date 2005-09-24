# testtalk.rb
# igneus 24.9.2005

# Talk is an object which wraps the two-sprites'-talk.

require 'test/unit'

require 'talk.rb'

class TestTalk < Test::Unit::TestCase

  include FreeVikings

TALK = <<EOT
--- %YAML:1.0
# Test talk of the two speakers.
speakers: 2
talk: - speaker: 0
        say: Good morning.
      - speaker: 1
        say: Good morning!
      - speaker: 0
        say: It's a nice day today, isn't it.
      - speaker: 1
        say: It isn't a very nice day actually.
      - speaker: 0
        say: My cat died in the morning.
EOT

  def setup
    @talk = Talk.new(TALK)
  end

  def testNumberOfSpeakers
    assert_equal 2, @talk.num_speakers, "Two speakers are defined in the data String."
  end

  def testDoesNotStartWithTooLittleSpeakers
    assert_raise(Talk::BadNumberOfSpeakersException, "The Talk is designed for two speakers and cannot be ran for one.") do
      @talk.start(Object.new)
    end
  end
end
