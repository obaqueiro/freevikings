# monkey-patching Gosu classes,
# usually in order to make them similar to the corresponding
# classes from the old RUDL library

module Gosu
  class Window
    alias w width
    alias h height
  end

  class Image
    alias w width
    alias h height
  end
end
