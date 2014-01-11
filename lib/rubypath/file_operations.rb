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
    with_path(*args) do |path|
      invoke_backend :touch, path
      Path path
    end
  end

  # Create a file at pointed location and all missing parent directories.
  #
  # Given arguments will be joined with current path before directories and
  # file is created.
  #
  # If file already exists nothing will be done.
  #
  # @example
  #   Path('/path/to/file.txt').mkfile
  #   #=> <Path:"/path/to/file.txt">
  #
  # @example
  #   Path('/').mkfile('path', 'to', 'file.txt')
  #   #=> <Path:"/path/to/file.txt">
  #
  # @return [Path] Path to created or existent file.
  #
  def mkfile(*args)
    with_path(*args) do |path|
      path.dir.mkpath if !path.exists? && path.dir && !path.dir.exists?
      if path.exists?
        raise Errno::ENOENT.new path.to_s unless path.file?
      else
        path.touch
      end
    end
  end

  # Search for a file in current directory or parent directories.
  #
  # Given search pattern can either be a regular expression or a shell glob
  # expression.
  #
  # @example
  #   Path.cwd.lookup('project.{yml,yaml}')
  #   #=> <Path:"/path/config.yml">
  #
  # @example
  #   Path.cwd.lookup(/config(_\d+).ya?ml/)
  #   #=> <Path:"/path/config_354.yaml">
  #
  # @example
  #   Path('~').lookup('*config', ::File::FNM_DOTMATCH)
  #   #=> <Path:"/gome/user/.gitconfig">
  #
  # @param pattern [String|RegExp] Expression file name must match.
  # @param flags [Integer] Additional flags. See {::File.fnmatch}.
  #   Defaults to `File::FNM_EXTGLOB`.
  # @return [Path] Path to found file or nil.
  #
  def lookup(pattern, flags = ::File::FNM_EXTGLOB)
    expand.ascend do |path|
      case pattern
      when String
        path.entries.each do |c|
          return path.join(c) if ::File.fnmatch?(pattern, c.name, flags)
        end
      when Regexp
        path.entries.each do |c|
          return path.join(c) if pattern =~ c.name
        end
      end
    end

    nil
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
