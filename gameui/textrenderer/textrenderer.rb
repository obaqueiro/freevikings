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

  attr_reader :font

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
      begin
        line_surface = @font.render(line, false, colour)
      rescue SDLError => sdle
        STDERR.puts "SDLError while rendering line '#{line}'"
        raise
      end
      surface.blit line_surface, [0, l * (@font.linesize)]
    end
  end

=begin
--- TextRenderer.create_text_box(width, text, colour=[255,255,255])
Returns a new (({RUDL::Surface})) with rendered text.
It is transparent (colorkey #ff00ff - HTML 'fuchsia')
=end

  def create_text_box(width, text, colour=DEFAULT_TEXT_COLOUR)
    height = height(text, width)
    surface = Surface.new [width, height]
    surface.fill [255,0,255]
    surface.set_colorkey [255,0,255]
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

  # Splits text into lines of max width line_width.
  # Returns Array of these lines.

  def make_lines(text, line_width)
    words = text.split(/\s/)
    debug { print "words: "; p words }

    lines = []

    line = ""
    # every iteration creates one well-long line
    while (words.size > 0) do
      #debug { puts words.size }

      # remove empty words
      while words.first == ''
        words.shift
      end

      if @font.size(line + " " + words.first)[0] <= line_width then
        # Word is appended to the line
        line += " " + words.shift
        # debug { "line width: " + @font.size(line).to_s }
      elsif @font.size(words.first)[0] > line_width then
        debug {
          print "line: '#{line}' size: '#{@font.size(line)[0]}' "
          puts "word: '#{words.first}' size: '#{@font.size(words.first)[0]}' max width: '#{line_width}'"
        }
        # Word is wider than the line can be; end current line and
        # add the BIG word as a new line
        lines.push line unless line == ''
        line = ""
        lines.push words.shift
      else
        # Line is too wide, so let's end it and start a new one
        lines.push line unless line == ''
        line = words.shift
      end
    end # while (words.size > 0)

    if line != '' then
      lines.push line
    end

    debug { 
      print "lines: "; p lines 
      puts
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
