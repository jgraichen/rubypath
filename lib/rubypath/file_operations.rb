class Path
  #@!group File Operations

  # Return base name without path.
  #
  # @return [String] Base name.
  #
  def name
    ::File.basename internal_path
  end
  alias_method :basename, :name

  # Create new file at pointed location or update modification time if file
  # exists.
  #
  # Given arguments will be joined before operating.
  #
  # @example
  #   Path('/path/to/file.txt').touch
  #   #=> <Path:"/path/to/file.txt">
  #
  # @example
  #   Path('/path/to').touch('file.txt')
  #   #=> <Path:"/path/to/file.txt">
  #
  # @return [Path] Path to touched file.
  #
  def touch(*args)
    with_path(*args) do |path|
      invoke_backend :touch, path
      Path path
    end
  end
end
