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
      check_data_validity

      set_initial_state
    end

    private

    def set_initial_state
      @next_sentence_index = nil
      @speakers = nil
    end

    public

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

      speakers.each do |s|
        if s == nil then
          raise ArgumentError, "Nil speaker given (on index #{speakers.index(s)})"
        end
      end

      @speakers = speakers

      @next_sentence_index = 0
    end

=begin
--- Talk#running?
Says if the talk has been started.
=end

    def running?
      ((! @speakers.nil?) and (! talk_completed?))
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

      if node == nil then
        raise EndOfSpeechException, "The talk has been finished. There is nothing more to be said."
      end

      speaker_index = node['speaker']
      sentence = node['say']

      @speakers[speaker_index].say(sentence)

      @next_sentence_index += 1

      if talk_completed? then
        return nil
      else
        return @next_sentence_index
      end
    end

=begin
--- Talk#talk_completed?
Says if the talk has been completed. (You can use this to avoid
calling to ((<Talk#next>)) on the completed talk which would raise 
an exception.)
If the talk hasn't been started yet, returns true.
=end
    def talk_completed?
      if @next_sentence_index then
        return @next_sentence_index >= @talk.size
      else
        return true
      end
    end

    # Reinitializes the Talk, so it can be started again.
    def restart
      set_initial_state
    end

    private

    # Checks if the object data (loaded from YAML document) are valid
    def check_data_validity
      @talk.each do |node|
        if node['speaker'] >= @num_speakers or
            node['speaker'] < 0 then
          raise SpeakerIDException, "Invalid speaker ID #{node['speaker']}; must be 0 <= id < #{@num_speakers}"
        end
      end
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

=begin
--- Talk::SpeakerIDException
Raised by ((<Talk.new>)) if an invalid speaker ID is used in the YAML file.
=end
    class SpeakerIDException < RuntimeError
    end

=begin
--- Talk::EndOfSpeechException
Raised by ((<Talk#next>)) if there is nothing more to be said.
=end
    class EndOfSpeechException < RuntimeError
    end
  end # class Talk
end # module FreeVikings
