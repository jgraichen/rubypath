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

  # Create directory and all missing parent directories.
  #
  # Given arguments will be joined with current path before directories
  # are created.
  #
  # @return [Path] Path to created directory.
  # @see #mkdir
  # @see ::FileUtils.mkdir_p
  #
  def mkpath(*args)
    with_path(*args) do |path|
      Backend.instance.mkpath path
      Path path
    end
  end
  alias_method :mkdir_p, :mkpath

  # Return list of entries in directory. That includes special directories
  # (`.`, `..`).
  #
  # Given arguments will be joined before children are listed for directory.
  #
  # @return [Array<Path>] Entries in directory.
  #
  def entries(*args)
    invoke_backend(:entries, internal_path).map(&Path)
  end
end
