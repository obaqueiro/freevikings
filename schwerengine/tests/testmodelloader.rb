# testmodelloader.rb
# igneus 3.1.2005

class TestModelLoader < Test::Unit::TestCase

  include SchwerEngine
  include SchwerEngine::Mock

  def setup
    @model = MockModel.new
  end

  def rect
    Rectangle.new 0,0,50,50
  end

  def testLoadOneSimpleImage
    src = <<EOXML
<model>
  <states>
    <state name="one" image="nobody.tga"/>
  </states>
</model>
EOXML

    Model::ModelLoader.new @model, src

    assert((@model.images['one'] != nil), "State 'one' should have got an image assigned.")
  end

  def testPreLoadOneSimpleImage
src = <<EOXML
<model>
  <load_pre>
    <image sym="nobody">nobody.tga</image>
  </load_pre>
  <states>
    <state name="one" sym="nobody"/>
  </states>
</model>
EOXML

    Model::ModelLoader.new(@model, src)
    assert((@model.images['one'] != nil), 
           "State 'one' should have got an image assigned.")
  end

  def testPreLoadAnimation
src = <<EOXML
<model>
  <load_pre>
    <image sym="nuby">nobody.tga</image>
    <animation sym="nobody_anim" delay="2">
      <image sym="nuby"/>
      <image>nobody.tga</image>
    </animation>
  </load_pre>
  <states>
    <state name="one" sym="nobody_anim"/>
  </states>
</model>
EOXML

    Model::ModelLoader.new(@model, src)
    assert_kind_of(Animation, @model.images['one'], 
           "State 'one' should have got an Animation assigned.")
  end
end
