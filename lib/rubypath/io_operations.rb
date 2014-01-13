class Path
  #@!group IO Operations

  # Write given content to file.
  #
  # @overload write(content, [..])
  #   Write given content to file. An existing file will be truncated otherwise
  #   a file will be created.
  #
  #   Additional arguments will be passed to {::IO.write}.
  #
  #   @example
  #     Path('/path/to/file.txt').write('CONTENT')
  #     #=> 7
  #
  #   @param content [String] Content to write to file.
  #
  # @overload write(content, offset, [..])
  #   Write content at specific position in file. Content will be replaced
  #   starting at given offset.
  #
  #   Additional arguments will be passed to {::IO.write}.
  #
  #   @example
  #     path.write('CONTENT', 4)
  #     #=> 7
  #     path.read
  #     #=> "1234CONTENT2345678"
  #
  #   @param content [String] Content to write to file.
  #   @param offset [Integer] Offset where to start writing. If nil file will
  #     be truncated.
  #
  # @see IO.write
  # @return [Path] Self.
  #
  def write(content, *args)
    invoke_backend :write, self, content, *args
    self
  end

  # Read file content from disk.
  #
  # @overload read([..])
  #   Read all content from file.
  #
  #   Additional arguments will be passed to {::IO.read}.
  #
  #   @example
  #     Path('file.txt').read
  #     #=> "CONTENT"
  #
  # @overload read(length, [..])
  #   Read given amount of bytes from file.
  #
  #   Additional arguments will be passed to {::IO.read}.
  #
  #   @example
  #     Path('file.txt').read(4)
  #     #=> "CONT"
  #
  #   @param length [Integer] Number of bytes to read.
  #
  # @overload read(length, offset, [..])
  #   Read given amount of bytes from file starting at given offset.
  #
  #   Additional arguments will be passed to {::IO.read}.
  #
  #   @example
  #     Path('file.txt').read(4, 2)
  #     #=> "NTEN"
  #
  #   @param length [Integer] Number of bytes to read.
  #   @param offset [Integer] Where to start reading.
  #
  # @see IO.read
  # @return [String] Read content.
  #
  def read(*args)
    invoke_backend :read, self, *args
  end
end
