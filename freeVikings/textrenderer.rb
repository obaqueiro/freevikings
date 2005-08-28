# textrenderer.rb
# igneus 24.7.2005

=begin
= TextRenderer
TextRenderer is an utility class to render images with blocks of text
using (({RUDL::TrueTypeFont})).
It's main goal is to simplify creation of help windows, dialog
windows, menus etc. for my Ruby-written computer games.
It is not defined inside the (({FreeVikings})) module, because it's general
and I am going to use it in more games.
=end

require 'RUDL'

class TextRenderer

  include RUDL

  DEBUG = false

  DEFAULT_TEXT_COLOUR = [255,255,255]

=begin
--- TextRenderer.new(font)
Creates a new ((<TextRenderer>)) for a (({RUDL::TrueTypeFont})) ((|font|)).
=end

  def initialize(font)
    @font = font
  end

=begin
--- TextRenderer#render(surface, width, text, colour=[255,255,255])
Prints the text onto the surface.
Arguments:
* ((|surface|)) - the destination (({RUDL::Surface}))
* ((|width|)) - maximal width of the printed text
* ((|text|)) - a String to be printed
* ((|colour|)) - a colour of the text in RUDL format (Array which contains 
  three numbers)
=end

  def render(surface, width, text, colour=DEFAULT_TEXT_COLOUR)
    lines = make_lines(text, width)

    lines.each_index do |l|
      line = lines[l]
      line_surface = @font.render(line, false, colour)
      surface.blit line_surface, [0, l * (@font.linesize)]
    end
  end

=begin
--- TextRenderer.create_text_box(width, text, colour=[255,255,255])
Returns a new (({RUDL::Surface})) with rendered text.
=end

  def create_text_box(width, text, colour=DEFAULT_TEXT_COLOUR)
    height = height(text, width)
    surface = Surface.new [width, height]
    render(surface, width, text, colour)
    return surface
  end

=begin
--- TextRenderer#height(text, width)
Returns a height (in pixels) of the (({RUDL::Surface})) with width ((|width|))
to fit in ((|text|)) which must be String.
=end

  def height(text, width)
    lines = make_lines(text, width)
    return lines.size * @font.linesize
  end

  private

  def debug
    # print caller.to_s + " "
    yield if DEBUG
  end

  # accepts a String, returns an Array of Strings

  def make_lines(text, line_width)
    words = text.split(/ /)
    debug { print "words: "; p words }

    lines = []

    # every iteration creates one well-long line
    while (words.size > 0) do
      line = ""

      # every iteration adds a word to the end of the line
      while (@font.size(line + " " + words.first)[0] <= line_width) do
        line += " " + words.shift
        debug { "line width: " + @font.size(line).to_s }
        break if (w = words.first).nil?
      end

      lines.push line

      # make a new line where \n
      while (i = lines.last.index("\n")) do
        new_line = lines.last.slice!(i..lines.last.size)
        new_line.slice!(0...1) # remove the EOL which is the first character
        lines.push(new_line)
      end # while (i = lines.last.index("\n"))
    end # while (words.size > 0)

    debug { 
      print "lines: "; p lines 
      print "words: "; p words
    }

    return lines
  end

end # class TextRenderer


###=======================###  Main program  ###============================###
# Tests the module TextRenderer if this file is executed like a standalone    #
#  script.                                                                    #
###=========================================================================###

if __FILE__ == $0 then

  include RUDL

  $win = DisplaySurface.new [640, 480]
  $font = RUDL::TrueTypeFont.new('fonts/adlibn.ttf', 16)

  renderer = TextRenderer.new $font

  # make a text in a border
  text = "Play\nfreeVikings\nand guide the three viking friends through some really dangerous places."
  w = 200
  h = renderer.height(text, w)
  surf = Surface.new [w,h]
  surf.fill [255,30,60]
  renderer.render(surf, w, text)
  $win.blit surf, [100, 100]

  $win.flip

  loop do
    exit if EventQueue.poll.is_a? KeyDownEvent
  end
end # main program
