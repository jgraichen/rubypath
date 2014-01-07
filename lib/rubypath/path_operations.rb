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
  #   #=> <Path "path/tmp">
  #
  # @example
  #   Path('~/tmp').expand
  #   #=> <Path "/home/user/tmp">
  #
  # @example
  #   Path('~oma/tmp').expand
  #   #=> <Path "/home/oma/tmp">
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
  # @return [Path] Parent path.
  #
  def dir
    return nil if %w(. /).include? internal_path

    dir = ::File.dirname internal_path
    dir.empty? ? nil : self.class.new(dir)
  end
  alias_method :dirname, :dir
  alias_method :parent, :dir

  # # Yield given block for path and each ancestor.
  # #
  # # @example
  # #
  # def ascend
  #   return to_enum(:ascend) unless block_given?

  #   path = self
  #   begin
  #     yield path
  #   end while (path = path.dir)
  #   self
  # end
  # alias_method :ancestors, :ascend

  # # Return given path as a relative path by just striping
  # # leading slashes.
  # #
  # # @example
  # #   Path.new('/path/to/file').as_relative
  # #   #=> <Path 'path/to/file'>
  # #
  # # @return [Path] Path transformed to relative path.
  # #
  # def as_relative
  #   if (rel_path = internal_path.gsub(/^\/+/, '')) != internal_path
  #     self.class.new rel_path
  #   else
  #     self
  #   end
  # end

  # # Return given path as a absolute path by just
  # # prepending a leading slash.
  # #
  # # @example
  # #   Path.new('path/to/file').as_absolute
  # #   #=> <Path '/path/to/file'>
  # #
  # # @return [Path] Path transformed to absolute path.
  # #
  # def as_absolute
  #   if internal_path[0] != '/'
  #     self.class.new "/#{internal_path}"
  #   else
  #     self
  #   end
  # end
end
