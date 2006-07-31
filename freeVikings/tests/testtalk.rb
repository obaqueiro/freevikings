# testtalk.rb
# igneus 24.9.2005

# Talk is an object which wraps the two-sprites'-talk.

require 'test/unit'

require 'talk.rb'

class TestTalk < Test::Unit::TestCase

  include FreeVikings

  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #
  # Constants which include the testing YAML data are at the end of the file. #
  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #

  def setup
    @talk = Talk.new(TALK)

    @sp1 = MockSpeaker.new
    @sp2 = MockSpeaker.new
  end

  def testNumberOfSpeakers
    assert_equal 2, @talk.num_speakers, "Two speakers are defined in the data String."
  end

  def testDoesNotStartWithTooLittleSpeakers
    assert_raise(Talk::BadNumberOfSpeakersException, "The Talk is designed for two speakers and cannot be ran for one.") do
      @talk.start(Object.new)
    end
  end

  def testDoesNotStartWithTooManySpeakers
    assert_raise(Talk::BadNumberOfSpeakersException, "The Talk is designed for two speakers and cannot be ran for three.") do
      @talk.start(Object.new, Object.new, Object.new)
    end
  end

  def testNext
    @talk.start(@sp1, @sp2)
    @talk.next()
    assert_equal("Good morning.", @sp1.last_speech, "The first speaker should have said 'Good morning.'. It's written so in the testing talk source.")
  end

  def testNextRaisesExceptionIfTalkHasNotBeenStarted
    assert_raise(Talk::TalkNotStartedException, "Talk hasn't been started, 'next' has no sense.") do
      @talk.next
    end
  end

  def testDoubleStartFails
    @talk.start(@sp1, @sp2)
    assert_raise(Talk::TalkRunningException, "The talk has already started. It cannot be started again until it's finished.") do
      @talk.start(@sp1, @sp2)
    end
  end

  def testExceptionAfterTheTalkIsFinished
    @talk.start(@sp1, @sp2)
    while not @talk.talk_completed? do
      @talk.next
    end

    assert_raise(Talk::EndOfSpeechException,
                 "The talk was started, ran until it finished and now "\
                 "it should raise an exception because there is nothing "\
                 "more to be said.") do
      @talk.next
    end
  end

  def testRunning
    @talk.start(@sp1, @sp2)
    assert @talk.running?, "Talk is running now."
  end

  def testNotRunningAfterTalkFinished
    @talk.start(@sp1, @sp2)
    while not @talk.talk_completed? do
      @talk.next
    end
    assert((not @talk.running?), "Talk has been just finished, it isn't running.")
  end

  def testCanRestartWhenNotRunning
    @talk.start(@sp1, @sp2)
    while @talk.running? do
      @talk.next
    end
    @talk.restart
    assert_nothing_raised("The talk isn't running, so we should be able to start it once more.") do
      @talk.start(@sp2, @sp1)
    end    
  end

  def testTooHighSpeakerNumber
    assert_raise(Talk::SpeakerIDException,
                 "Two speakers are declared, speaker no.2 would be the third "\
                 "one. An exception must be raised.") do
      Talk.new OVERSPEAKER_TALK
    end
  end


  class MockSpeaker
    attr_accessor :last_speech
    def say(str)
      @last_speech = str
    end
  end

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

OVERSPEAKER_TALK = <<EOT
--- %YAML:1.0
# Test talk of the two speakers.
speakers: 2
talk: - speaker: 2
        say: Good morning.
EOT


end
