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

  # Create directory.
  #
  # Given arguments will be joined with current path before directory is
  # created.
  #
  # @raise [Errno::ENOENT] If parent directory could not created.
  # @return [Path] Path to created directory.
  # @see #mkpath
  #
  def mkdir(*args)
    with_path(*args) do |path|
      Backend.instance.mkdir path
      Path path
    end
  end

  def mkpath(*args)
    with_path(*args) do |path|
      Backend.instance.mkpath path
      Path path
    end
  end
  alias_method :mkdir_p, :mkpath
end
