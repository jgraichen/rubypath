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
  # @example
  #   Path('/path/to/file.txt').touch
  #   #=> <Path:"/path/to/file.txt">
  #
  # @return [Path] Path to touched file.
  #
  def touch(*args)
    invoke_backend :touch, path
    self
  end

  # TODO
  def mtime
    invoke_backend :mtime
  end

  # TODO
  def mtime=(time)
    invoke_backend :mtime=, internal_path, time
  end
end
