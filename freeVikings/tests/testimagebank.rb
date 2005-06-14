# testimagebank.rb
# igneus 11.6.2005

# Testy pro tridu ImageBank

require 'test/unit'

class TestImageBank < Test::Unit::TestCase

  include FreeVikings

  def setup
    @bank = ImageBank.new self

    @w = 15
    @h = 30
  end

  def rect
    Rectangle.new(0,0,@w,@h)
  end

  def testImageWithBadSizes
    image = Mock::MockImage.new
    image.w = 90
    image.h = 1020
    image.name = 'mockimage'

    assert_raise(ImageBank::ImageWithBadSizesException, "An image with sizes different to the sprite's was added, an exception should be thrown.") do
      @bank.add_pair 'some state', image
    end
  end

  def testLoadNonexistingImage
    filename = "nonexistingimagefile.nonext"
    assert_raise(Image::ImageFileNotFoundException, "Image file #{filename} doesn't exist, an exception must be thrown.") do
      Image.new(filename)
    end
  end
end


FreeVikings::Mock::MockImage = Struct.new("MockImage", :w, :h, :name)