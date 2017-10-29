# textrenderer.rb
# igneus 24.7.2005

require 'RUDL'

# TextRenderer is an utility class to render images with blocks of text
# using RUDL::TrueTypeFont.
# It's main goal is to simplify creation of help windows, dialog
# windows, menus etc. for my Ruby-written computer games.
# It is not defined inside the FreeVikings module, because it's general
# and I am going to use it in more games.

class TextRenderer

  include RUDL

  DEBUG = false

  DEFAULT_TEXT_COLOUR = [255,255,255]

  # Creates a new TextRenderer for a RUDL::TrueTypeFont font.

  def initialize(font)
    @font = font
  end

  attr_reader :font

  # Prints the text onto the surface.
  # Arguments:
  # surface::  the destination RUDL::Surface
  # width:: maximal width of the printed text
  # text:: a String to be printed
  # colour:: a colour of the text in RUDL format (Array which contains 
  #          three numbers)

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

  # Returns a new RUDL::Surface with rendered text.
  # Background is transparent (colorkey #ff00ff - HTML 'fuchsia') by default,
  # but you can set background colour to overwrite this.

  def create_text_box(width, text, colour=DEFAULT_TEXT_COLOUR, bgcolour=nil)
    height = height(text, width)
    surface = Surface.new [width, height]
    if bgcolour == nil then
      surface.fill [255,0,255]
      surface.set_colorkey [255,0,255]
    else
      surface.fill bgcolour
    end
    render(surface, width, text, colour)
    return surface
  end

  # Returns a height (in pixels) of the RUDL::Surface with width +width+
  # to fit in +text+ which must be String.

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
    a = text.split(/\n/)
    words2d = a.collect {|s| s.split(/\s/)}

    debug { p words2d }

    lines = [] # results end up here

    words = [] # temporary variable

    line = ""

    while (words2d.size > 0 || words.size > 0) do
      if words.empty? then
        words = words2d.shift
        if line != '' then
          lines.push line
          line = ''
        end
      end

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

  $win.blit(renderer.create_text_box(w*1.5, text, [0,255,100], [255,255,255]), [100,300])

  $win.flip

  loop do
    EventQueue.get.each do |e|
      exit if e.is_a?(KeyDownEvent) || e.is_a?(QuitEvent)
      sleep 0.5
    end
  end
end # main program
