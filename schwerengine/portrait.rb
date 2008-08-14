# portrait.rb
# igneus 26.11.2005

=begin
= NAME
Portrait

= DESCRIPTION
A ((<Portrait>)) keeps three images. They are called active, unactive and 
kaput. Every of the three vikings has his own ((<Portrait>)) object with 
his face's images used on the BottomPanel.

= Superclass
Object
=end

module SchwerEngine
  class Portrait

=begin
--- Portrait.new(active_path, unactive_path, kaput_path)
Accepts two file paths, loads the images and creates a new (({Portrait})).
=end

    def initialize(active_path, unactive_path, kaput_path)
      @active = Image.load(active_path)
      @unactive = Image.load(unactive_path)
      @kaput = Image.load(kaput_path)
    end

=begin
--- Portrait#active
Returns the active (usually colourful) variant of the portrait.
=end

    def active
      @active.image
    end

=begin
--- Portrait#image
Alias for ((<Portrait#active>)) present only for compatibility
with ((<Image>)) here.
=end

    alias_method :image, :active

=begin
--- Portrait#unactive
Returns the unactive (usually black and white) variant of the portrait.
=end

    def unactive
      @unactive.image
    end

    def kaput
      @kaput.image
    end
  end # class Portrait
end # module SchwerEngine
