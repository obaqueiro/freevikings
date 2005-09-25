# talk.rb
# igneus 24.9.2005

=begin
= Talk
A ((<Talk>)) instance wraps the contents of the dialog of the two speakerss
(usually some intelligent (({Monster})) and a (({Viking}))).
Speaker is any object which responds to message (({say})).
=end

require 'yaml'

module FreeVikings

  class Talk

=begin
--- Talk.new(yaml_source)
((|yaml_source|)) must be a (({String})) (filename / YAML document).
=end

    def initialize(yaml_source)
      @doc = YAML.load yaml_source
      @num_speakers = @doc['speakers']
      @talk = @doc['talk']

      @next_sentence_index = nil
      @speakers = nil
    end

=begin
--- Talk#num_speakers
Returns the number of speakers who must take part in the ((<Talk>)).
=end

    attr_reader :num_speakers

=begin
--- Talk#start(*speakers)
Initializes the talk of the ((|speakers|)).
Raises ((<Talk::BadNumberOfSpeakersException>)) if too little or too many
speakers are given (use ((<Talk#num_speakers>)) to find out how many
speakers are needed).
If the ((<Talk>))'s already started and hasn't finished yet, 
((<Talk::TalkRunningException>)) is raised.
=end

    def start(*speakers)
      unless @speakers.nil?
        raise TalkRunningException, "The talk is already running (now going to process sentence #{@next_sentence_index + 1}/#{@talk.size}), it cannot be started until it's finished."
      end

      if speakers.size != @num_speakers then
        raise BadNumberOfSpeakersException, "This Talk is for #{@num_speakers} so it cannot be started with #{speakers.size}."
      end

      @speakers = speakers

      @next_sentence_index = 0
    end

=begin
--- Talk#running?
=end

    def running?
      return ! @speakers.nil?
    end

=begin
--- Talk#next
Makes the next sentence from the ((<Talk>)) said.
It's realized by call to some speaker's (({say})) method.
Returns a number of sentence said or nil if the last sentence has just
been said.

Raises ((<Talk::TalkNotStartedException>)) if ((<Talk#start>)) has not been
called yet or if the ((<Talk>))'s finished.
=end

    def next
      if @next_sentence_index.nil? or
          @speakers.nil? then
        raise TalkNotStartedException, "Talk hasn't been started by 'start' or has finished yet."
      end

      node = @talk[@next_sentence_index]
      speaker_index = node['speaker']
      sentence = node['say']

      @speakers[speaker_index].say(sentence)

      @next_sentence_index += 1

      if talk_completed? then
        reinitialize_internals
        return nil
      else
        return @next_sentence_index
      end
    end

    private

    def talk_completed?
      @next_sentence_index >= @talk.size
    end

    # Reinitializes the Talk, so it can be started again.
    def reinitialize_internals
      @next_sentence_index = 0
      @speakers = nil
    end

    public

=begin
== Exception classes

--- Talk::BadNumberOfSpeakersException
Raised by ((<Talk#start>)) if the number of speakers given isn't the same 
as ((<Talk#num_speakers>)).
=end

    class BadNumberOfSpeakersException < RuntimeError
    end

=begin
--- Talk::TalkNotStartedException
Raised by ((<Talk#next>)) if ((<Talk#start>)) has not been already called
(the talk hasn't started, so no next sentence can be said).
=end

    class TalkNotStartedException < RuntimeError
    end

=begin
--- Talk::TalkRunningException
Raised by ((<Talk#start>)) if the ((<Talk>)) has already been started and 
hasn't been finished yet.
=end

    class TalkRunningException < RuntimeError
    end
  end # class Talk
end # module FreeVikings
