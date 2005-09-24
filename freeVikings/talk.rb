# talk.rb
# igneus 24.9.2005

=begin
= Talk
A ((<Talk>)) instance wraps the contents of the dialog of the two (({Sprite}))s
(usually some intelligent (({Monster})) and a (({Viking}))).
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
    end

=begin
--- Talk.num_speakers
Returns the number of speakers who must take part in the ((<Talk>)).
=end

    attr_reader :num_speakers

    def start(*speakers)
      if speakers.size != @num_speakers then
        raise BadNumberOfSpeakersException, "This Talk is for #{@num_speakers} so it cannot be started with #{speakers.size}."
      end
    end

    class BadNumberOfSpeakersException < RuntimeError
    end
  end # class Talk
end # module FreeVikings
