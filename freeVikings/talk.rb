# talk.rb
# igneus 24.9.2005

require 'yaml'

module FreeVikings
  
  # A Talk instance wraps the contents of the dialog of the two speakerss
  # (usually some intelligent Monster and a Viking).
  # Speaker is any object which includes module Talkable.

  class Talk

    # yaml_source must be a File or String with YAML
    # document (not a filename!)

    def initialize(yaml_source)
      @doc = YAML.load yaml_source

      check_data_validity

      @num_speakers = @doc['speakers']
      @talk = @doc['talk']

      set_initial_state
    end

    private

    def set_initial_state
      @next_sentence_index = nil
      @speakers = nil
    end

    public

    # Returns the number of speakers who must take part in the Talk.

    attr_reader :num_speakers

    # Initializes the talk of the speakers.
    # Raises Talk::BadNumberOfSpeakersException if too little or too many
    # speakers are given (use Talk#num_speakers to find out how many
    # speakers are needed).
    # If the Talk's already started and hasn't finished yet, 
    # Talk::TalkRunningException is raised.

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

    # Says if the talk has been started.

    def running?
      ((! @speakers.nil?) and (! talk_completed?))
    end

    # Makes the last said sentence disappeared and
    # next sentence said.
    # Returns a number of sentence said or nil if the last sentence has just
    # been said.
    #
    # Raises Talk::TalkNotStartedException if Talk#start has not been
    # called yet or if the Talk's finished.
    #
    # If called after the last sentence, makes just the last sentence 
    # disappeared. If called once more, raises Talk::EndOfSpeechException.

    def next
      if @next_sentence_index.nil? or
          @speakers.nil? then
        raise TalkNotStartedException, "Talk hasn't been started by 'start' or has finished already."
      end

      # everything finished -> exception
      if @next_sentence_index > @talk.size then
        raise EndOfSpeechException, "The talk has been finished. There is nothing more to be said."
      end

      # Last sentence must disappear
      if @next_sentence_index >= 1 then
        last_speaker_i = @talk[@next_sentence_index-1]['speaker']
        @speakers[last_speaker_i].silence_please
      end

      # We made disappear last sentence:
      if @next_sentence_index == @talk.size then
        @next_sentence_index += 1
        return nil
      end

      node = @talk[@next_sentence_index]

      speaker_index = node['speaker']
      sentence = node['say']
      
      @speakers[speaker_index].say(sentence)

      @next_sentence_index += 1

      return @next_sentence_index
    end

    # Says if the talk has been completed. (You can use this to avoid
    # calling to Talk#next on the completed talk which would raise 
    # an exception.)
    # If the talk hasn't been started yet, returns true.

    def talk_completed?
      if @next_sentence_index then
        return @next_sentence_index >= (@talk.size + 1)
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
      if ! (@doc['speakers'].kind_of? Integer) then
        raise TalkDataInvalidException, "Number of speakers not given."
      end
      if ! (@doc['talk'].kind_of? Array) then
        raise TalkDataInvalidException, "Array of talk nodes not given."
      end
      @doc['talk'].each_with_index do |node,i|
        if ! (node['speaker'].kind_of? Integer) then
          raise TalkDataInvalidException, "Invalid speaker id '#{node['speaker']}' in node '#{i}'"
        end
        if node['speaker'] >= @doc['speakers'] or
            node['speaker'] < 0 then
          raise TalkDataInvalidException, "Invalid speaker ID #{node['speaker']} in node '#{i}'; must be 0 <= id < #{@doc['speakers']}"
        end
      end
    end

    public

    # == Exception classes

      class TalkDataInvalidException < ArgumentError
      end

      # Raised by Talk#start if the number of speakers given isn't the same 
      # as Talk#num_speakers.

    class BadNumberOfSpeakersException < ArgumentError
    end

    # Raised by Talk#next if Talk#start has not been already called
    # (the talk hasn't started, so no next sentence can be said).

    class TalkNotStartedException < RuntimeError
    end

    # Raised by Talk#start if the Talk has already been started and 
    # hasn't been finished yet.

    class TalkRunningException < RuntimeError
    end

    # Raised by Talk#next if there is nothing more to be said.

    class EndOfSpeechException < RuntimeError
    end
  end # class Talk
end # module FreeVikings
