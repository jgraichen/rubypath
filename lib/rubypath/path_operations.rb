class Path
  #@!group Path Operations

  # Join path with given arguments.
  #
  # @overload initialize([[Path, String, #to_path, #path, #to_s], ...]
  # @return [Path]
  #
  def join(*args)
    parts = args.flatten
    case parts.size
    when 0
      self
    when 1
      join = Path parts.shift
      join.absolute? ? join : Path(::File.join(self.path, join.path))
    else
      join(parts.shift).join(*parts)
    end
  end

  # Iterate over all file names.
  #
  # @overload each_filename
  #   Return a enumerator to iterate over all file names.
  #
  #   @example Iterate over file names using a enumerator
  #     enum = Path('/path/to/file.txt').each_filename
  #     enum.each{|fn| puts fn}
  #     # => "path"
  #     # => "to"
  #     # => "file.txt"
  #
  #   @example Map each file name and create a new path
  #     path = Path('/path/to/file.txt')
  #     Path path.each_filename.map{|fn| fn.length}
  #     # => <Path:"/4/2/8">
  #
  #   @return [Enumerator] Return a enumerator for all file names.
  #
  # @overload each_filename(&block)
  #   Yield given block for each file name.
  #
  #   @example Print each file name
  #     Path('/path/to/file.txt').each_filename{|fn| puts fn}
  #     # => "path"
  #     # => "to"
  #     # => "file.txt"
  #
  #   @param block [Proc] Block to invoke with each filename. If no block is given
  #     an enumerator will returned.
  #   @return [self] Self.
  #
  def each_filename(&block)
    rv = Pathname(self.path).each_filename &block
    block ? self : rv
  end

  # Return an array with all file names.
  #
  # @example
  #   Path('path/to/file').filenames
  #   # => ["path", "to", "file"]
  #
  # @example
  #   Path('/path/to/file').filenames
  #   # => ["path", "to", "file"]
  #
  # @return [Array<String>] File names.
  #
  def filenames
    each_filename.to_a
  end

  # Converts a pathname to an absolute pathname. Given arguments will be
  # joined to current path before expanding path. Relative paths are referenced
  # from the current working directory of the process unless the `:base` option
  # is set, which will be used as the starting point.
  #
  # The given pathname may start with a “~”, which expands to the process
  # owner’s home directory (the environment variable HOME must be set
  # correctly). “~user” expands to the named user’s home directory.
  #
  # @example
  #   Path('path/to/../tmp').expand
  #   #=> <Path:"path/tmp">
  #
  # @example
  #   Path('~/tmp').expand
  #   #=> <Path:"/home/user/tmp">
  #
  # @example
  #   Path('~oma/tmp').expand
  #   #=> <Path:"/home/oma/tmp">
  #
  # @example
  #   Path('~/tmp').expand('../file.txt')
  #   #=> <Path:"/home/user/file.txt">
  #
  # @return [Path] Expanded path.
  # @see ::File#expand_path
  #
  def expand(*args)
    opts = Hash === args.last ? args.pop : Hash.new

    with_path(*args) do |path|
      base = Path.like_path(opts[:base] || Backend.instance.getwd)
      if (expanded_path = Backend.instance.expand_path(path, base)) != internal_path
        Path expanded_path
      else
        self
      end
    end
  end
  alias_method :expand_path, :expand
  alias_method :absolute, :expand
  alias_method :absolute_path, :expand

  # Check if path consists of only a filename.
  #
  # @example
  #   Path('file.txt').only_filename?
  #   #=> true
  #
  # @return [Boolean] True if path consists of only a filename.
  #
  def only_filename?
    internal_path.index(Path.separator).nil?
  end

  # Return path to parent directory. If path is already an absolute or relative
  # root nil will be returned.
  #
  # @example Get parent directory:
  #   Path.new('/path/to/file').dir.path
  #   #=> '/path/to'
  #
  # @example Try to get parent of absolute root:
  #   Path.new('/').dir
  #   #=> nil
  #
  # @example Try to get parent of relative root:
  #   Path.new('.').dir
  #   #=> nil
  #
  # @return [Path] Parent path or nil if path already points to an absolute
  #   or relative root.
  #
  def dirname
    return nil if %w(. /).include? internal_path

    dir = ::File.dirname internal_path
    dir.empty? ? nil : self.class.new(dir)
  end
  alias_method :parent, :dirname

  # Yield given block for path and each ancestor.
  #
  # @example
  #   Path('/path/to/file.txt').ascend{|path| p path}
  #   #<Path:/path/to/file.txt>
  #   #<Path:/path/to>
  #   #<Path:/path>
  #   #<Path:/>
  #   #=> <Path:/path/to/file.txt>
  #
  # @example
  #   Path('path/to/file.txt').ascend{|path| p path}
  #   #<Path:path/to/file.txt>
  #   #<Path:path/to>
  #   #<Path:path>
  #   #<Path:.>
  #   #=> <Path:path/to/file.txt>
  #
  # @yield |path| Yield path and ancestors.
  # @yieldparam path [Path] Path or ancestor.
  # @return [Path] Self.
  #
  def ascend
    return to_enum(:ascend) unless block_given?

    path = self
    begin
      yield path
    end while (path = path.parent)
    self
  end
  alias_method :each_ancestors, :ascend

  # Return an array of all ancestors.
  #
  # @example
  #   Path('/path/to/file').ancestors
  #   # => [<Path:/path/to/file.txt>, <Path:/path/to>, <Path:/path>, <Path:/>]
  #
  # @return [Array<Path>] All ancestors.
  #
  def ancestors
    each_ancestors.to_a
  end

  # Return given path as a relative path by just striping leading slashes.
  #
  # @example
  #   Path.new('/path/to/file').as_relative
  #   #=> <Path 'path/to/file'>
  #
  # @return [Path] Path transformed to relative path.
  #
  def as_relative
    if (rel_path = internal_path.gsub(/^\/+/, '')) != internal_path
      Path rel_path
    else
      self
    end
  end

  # Return given path as a absolute path by just prepending a leading slash.
  #
  # @example
  #   Path.new('path/to/file').as_absolute
  #   #=> <Path '/path/to/file'>
  #
  # @return [Path] Path transformed to absolute path.
  #
  def as_absolute
    if internal_path[0] != '/'
      Path "/#{internal_path}"
    else
      self
    end
  end
end
