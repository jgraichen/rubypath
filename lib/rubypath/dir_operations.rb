class Path
  class << self

    # Returns the current working directory.
    #
    # @return [Path] Current working directory.
    # @see ::Dir.getwd
    #
    def getwd
      new Backend.instance.getwd
    end
    alias :cwd :getwd
    alias :pwd :getwd
  end
end
