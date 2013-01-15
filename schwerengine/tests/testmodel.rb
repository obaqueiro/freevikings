# testimages.rb
# igneus 11.6.2005

# Tests for class Model (some days before it was called ImageBank)

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!! TESTS OF MODEL LOADING AREN'T INCLUDED HERE BUT IN A SEPARATE !!!
# !!! TEST CASE IN FILE testmodelloader.rb.                         !!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

require 'test/unit'

class TestModel < Test::Unit::TestCase

  include SchwerEngine

  def setup
    @bank = Model.new

    @w = 50
    @h = 50
  end

  def rect
    Rectangle.new(0,0,@w,@h)
  end

  def testImageWithBadSizes
    image = Mock::MockImage.new
    image.w = 90
    image.h = 1020
    image.name = 'mockimage'

    image2 = image.dup
    image2.w = 100

    @bank.add_pair 'no state', image

    assert_raise(Model::ImageWithBadSizesException, "An image with sizes different to the first one's was added, an exception should be thrown.") do
      @bank.add_pair 'some state', image2
    end
  end

  def testLoadNonexistingImage
    filename = "nonexistingimagefile.nonext"
    assert_raise(Image::ImageFileNotFoundException, "Image file #{filename} doesn't exist, an exception must be thrown.") do
      Image.new(filename)
    end
  end
end


SchwerEngine::Mock::MockImage = Struct.new("MockImage", :w, :h, :name)
