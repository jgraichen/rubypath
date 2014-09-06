class Path
  # @!group Path Operations

  # Join path with given arguments.
  #
  # @overload initialize([[Path, String, #to_path, #path, #to_s], ...]
  #   Join all given arguments to build a new path.
  #
  #   @example
  #     Path('/').join('test', %w(a b), 5, Pathname.new('file'))
  #     # => <Path:"/test/a/b/5/file">
  #
  # @return [Path]
  #
  def join(*args)
    parts = args.flatten
    case parts.size
      when 0
        self
      when 1
        join = Path parts.shift
        join.absolute? ? join : Path(::File.join(path, join.path))
      else
        join(parts.shift).join(*parts)
    end
  end

  # Iterate over all path components.
  #
  # @overload each_component
  #   Return a enumerator to iterate over all path components.
  #
  #   @example Iterate over path components using a enumerator
  #     enum = Path('/path/to/file.txt').each_component
  #     enum.each{|fn| puts fn}
  #     # => "path"
  #     # => "to"
  #     # => "file.txt"
  #
  #   @example Map each path component and create a new path
  #     path = Path('/path/to/file.txt')
  #     Path path.each_component.map{|fn| fn.length}
  #     # => <Path:"/4/2/8">
  #
  #   @return [Enumerator] Return a enumerator for all path components.
  #
  # @overload each_component(&block)
  #   Yield given block for each path components.
  #
  #   @example Print each file name
  #     Path('/path/to/file.txt').each_component{|fn| puts fn}
  #     # => "path"
  #     # => "to"
  #     # => "file.txt"
  #
  #   @param block [Proc] Block to invoke with each path component.
  #     If no block is given an enumerator will returned.
  #   @return [self] Self.
  #
  def each_component(opts = {}, &block)
    rv = if opts[:empty]
           # split eats leading slashes
           ary = path.split(Path.separator)
           # so add an empty string if path ends with slash
           ary << '' if path[-1] == Path.separator
           ary.each(&block)
         else
           Pathname(path).each_filename(&block)
         end
    block ? self : rv
  end

  # Return an array with all path components.
  #
  # @example
  #   Path('path/to/file').components
  #   # => ["path", "to", "file"]
  #
  # @example
  #   Path('/path/to/file').components
  #   # => ["path", "to", "file"]
  #
  # @return [Array<String>] File names.
  #
  def components(*args)
    each_component(*args).to_a
  end

  # Converts a pathname to an absolute pathname. Given arguments will be
  # joined to current path before expanding path. Relative paths are referenced
  # from the current working directory of the process unless the `:base` option
  # is set, which will be used as the starting point.
  #
  # The given pathname may start with a "~", which expands to the process
  # owner's home directory (the environment variable HOME must be set
  # correctly). "~user" expands to the named user's home directory.
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
    opts = args.last.is_a?(Hash) ? args.pop : {}

    with_path(*args) do |path|
      base          = Path.like_path(opts[:base] || Backend.instance.getwd)
      expanded_path = Backend.instance.expand_path(path, base)
      if expanded_path != internal_path
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
    loop do
      yield path
      break unless (path = path.parent)
    end

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

  # Return a relative path from the given base path to the receiver path.
  #
  # Both paths need to be either absolute or relative otherwise an error
  # will be raised. The file system will not be accessed and no symlinks are
  # assumed.
  #
  # @example
  #   relative = Path('src/lib/module1/class.rb')
  #     .relative_from('src/lib/module2')
  #   #=> <Path '../module1/class.rb'>
  #
  # @return [Path] Relative path from argument to receiver.
  # @see Pathname#relative_path_from
  #
  def relative_from(base)
    base, path = Path(base).cleanpath, cleanpath

    return Path '.' if base == path

    if (base.relative? && path.absolute?) || (base.absolute? && path.relative?)
      raise ArgumentError.new \
        "Different prefix: #{base.inspect} and #{path.inspect}"
    end

    base, path = base.components(empty: true), path.components(empty: true)
    base.shift && path.shift while base.first == path.first && !(base.empty? || path.empty?)

    Path(*((['..'] * base.size) + path))
  end
  alias_method :relative_path_from, :relative_from

  # Return cleaned path with all dot components removed.
  #
  # No file system will accessed and not symlinks will be resolved.
  #
  # @example
  #   Path('./file.txt').cleanpath
  #   #=> <Path file.txt>
  #
  # @example
  #   Path('path/to/another/../file/../../txt').cleanpath
  #   #=> <Path path/txt>
  #
  # @return [Path] Cleaned path.
  #
  def cleanpath
    path = Pathname.new(self).cleanpath
    if path == internal_path
      self
    else
      if internal_path[-1] == Path.separator
        Path path, ''
      else
        Path path
      end
    end
  end
end
