# images.rb
# igneus 20.1.2004

module SchwerEngine

  # Model is an associative container which binds a Sprite, it's states
  # and images for these states.

  class Model

    # hash:: is an optional argument. It can contain hash with String
    #        keys and Image compatible values. It is used as a set of
    #        state=>image pairs if supplied.
    #
    # Example:
    # Let's have a Sprite bar. We want to make a Model
    # for it.
    #
    # i = Image.load 'foo.png'
    #
    # - one way of doing things
    #
    #   bank = Model.new(bar)
    #   bank.add_pair 'foo_state', i
    #
    # - another way which is as good as the first one
    #
    #   bank = Model.new(bar, {'foo_state' => i})

    def initialize(hash=nil)
      @log = Log4r::Logger['images log']

      @log.info "Creating a new Model. #{ hash ? "Pre-prepared images hash was provided." : "." }"

      @images = Hash.new
      if hash then
        hash.each_key {|key| add_pair(key, hash[key])}
      end
    end

    # Loads a new Model from a valid REXML-parsable XML source
    # xml_source and returns it.

    def Model.load_new(xml_source)
      m = Model.new

      ModelLoader.new(m, xml_source)

      return m
    end

    # Associates the SchwerEngine::Image object with a state state 
    # (usually a String, eventually a Numeric, a boolean value or something 
    # else). It controls if the image has sizes equal to the sizes 
    # of the sprite which is  the Model's owner. If the sizes aren't same, 
    # RuntimeError is thrown.
    # This exception is thrown after the image is associated with the state, 
    # so you can just catch the exception and go on without problems.
    # You may avoid the exception by setting argument 'check_sizes' to false.

    def add_pair(state, image_object, check_sizes=true)
      @log.debug "Associating image #{image_object.to_s} - #{image_object.name} with a state #{state.to_s}"

      # The image must be added before the bad-sizes exception is raised.
      # Sometimes you need to have images of different sizes, so you just 
      # catch the exception and everything's all right.
      @images[state] = image_object

      if defined?(@width) then
        if (image_object.w != @width or
            image_object.h != @height) &&
            check_sizes then
          raise ImageWithBadSizesException, "Image of sizes "\
          "#{image_object.w}x#{image_object.h} inserted. (Previously "\
          "inserted images sized #{@widthx}#{@height} - usually you want "\
          "all the images in the Model to be of the same size)" 
        end        
      else
        @width = image_object.w
        @height = image_object.h
      end
      
      return self
    end

    # Returns the Image for owner's recent state.
    # Argument sprite is an object which responds to state.

    def image(sprite)
      begin
        @images[sprite.state.to_s].image
      rescue NoMethodError
	raise NoImageAssignedException.new(sprite.state)
      end
    end

    # This exception is thrown when an image which has different sizes than
    # the owner is added into an Model. It's important that the exception
    # is thrown just after the image is added, so if you expect it, you
    # can catch the exception and carry on whistling...
    class ImageWithBadSizesException < RuntimeError
    end

    # Exceptions of this type are thrown by Model#image if there
    # is no image for the owner's state in the Model.
    class NoImageAssignedException < RuntimeError
      def initialize(state)
        @message = "No image assigned for a state #{state.to_s}."
      end
      attr_reader :message
      alias_method :to_s, :message
    end # class NoImageAssignedException

    # Small objects used to load Model from XML source

    class ModelLoader

      def initialize(model, xml_source)
        @model = model
        @src = xml_source
        @doc = REXML::Document.new xml_source

        @named_images = {}

        load_definitions        
        load_states
      end

      private

      # loads definitions from 'load_pre' section
      def load_definitions
        return unless @doc.root.elements['load_pre'] != nil

        @doc.root.elements['load_pre'].each_element do |element|
          case element.name
          when 'image'
            load_image(element)
          when 'animation'
            load_animation(element)
          else
            raise "Unknown element '#{element.name}' found in Model source #@src."
          end
        end
      end

      def load_image(element)
        symbolic_name = element.attributes['sym']
        if element.has_text? then
          image = element.text
          @named_images[symbolic_name] = Image.load image
        else
          source_sym = element.attributes['srcsym']
          operation = element.attributes['operation']

          if (! source_sym) || (! operation) then
            raise "Malformed element 'image'."
          end

          unless @named_images[source_sym]
            raise "Unknown image with sym '#{source_sym}'"
          end

          case operation
          when 'mirror-x'
            @named_images[symbolic_name] = @named_images[source_sym].mirror_x
          else
            raise "Unknown operation '#{operation}'"
          end
        end
      end

      def load_animation(element)
        delay = (element.attributes['delay'] or Animation::DEFAULT_DELAY).to_f
        symbolic_name = element.attributes['sym']

        anim = Animation.new delay

        element.each_element('image') do |image|
          if image.has_text? then
            anim.push Image.load(image.text)
          elsif image.attributes['sym'] != nil
            anim.push @named_images[image.attributes['sym']]
          else
            raise "Element 'image' with neither text or 'sym' attribute found in 'load_pre' section of Model source #@src."
          end
        end

        @named_images[symbolic_name] = anim
      end

      # load state-image pairs from 'states' section
      def load_states
        @doc.root.elements['states'].each_element("state") do |state|
          state_name = state.attributes['name']

          if state.attributes['image'] != nil then
            state_image = Image.load(state.attributes['image'])
          elsif state.attributes['sym'] != nil then
            sym = state.attributes['sym']

            if @named_images[sym] == nil then
              raise "No image assigned in 'load_pre' section of Model source #@src to symbolic name '#{sym}'."
            end

            state_image = @named_images[sym]
          end

          @model.add_pair state_name, state_image
        end
      end
    end # class ModelLoader
  end # class Model
end # module SchwerEngine
