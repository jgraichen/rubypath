# frozen_string_literal: true
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

    def glob(pattern, flags = nil)
      flags = default_glob_flags(flags)

      if block_given?
        Backend.instance.glob(pattern, flags) {|path| yield Path path }
      else
        Backend.instance.glob(pattern, flags).map(&Path)
      end
    end

    # @!visibility private
    #
    def default_glob_flags(flags)
      if flags.nil? && defined?(::File::FNM_EXTGLOB)
        ::File::FNM_EXTGLOB
      else
        flags.to_i
      end
    end
  end

  # @!group Directory Operations

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
  alias mkdir_p mkpath

  # Return list of entries in directory. That includes special directories
  # (`.`, `..`).
  #
  # Given arguments will be joined before children are listed for directory.
  #
  # @return [Array<Path>] Entries in directory.
  #
  def entries(*_args)
    invoke_backend(:entries, internal_path).map(&Path)
  end

  #
  def glob(pattern, flags = nil, &block)
    Path.glob(::File.join(escaped_glob_path, pattern), flags, &block)
  end

  # Removes file or directory. If it's a directory it will be removed
  # recursively.
  #
  # WARNING: This method causes local vulnerability if one of parent
  # directories or removing directory tree are world writable (including
  # `/tmp`, whose permission is 1777), and the current process has strong
  # privilege such as Unix super user (root), and the system has symbolic link.
  # For secure removing see {#safe_rmtree}.
  #
  # @return [Path] Path to removed file or directory.
  #
  def rmtree(*args)
    with_path(*args) do |path|
      invoke_backend :rmtree, internal_path
      Path path
    end
  end
  alias rm_rf rmtree

  # Removes file or directory. If it's a directory it will be removed
  # recursively.
  #
  # This method uses #{FileUtils#remove_entry_secure} to avoid TOCTTOU
  # (time-of-check-to-time-of-use) local security vulnerability of {#rmtree}.
  # {#rmtree} causes security hole when:
  #
  # * Parent directory is world writable (including `/tmp`).
  # * Removing directory tree includes world writable directory.
  # * The system has symbolic link.
  #
  # @return [Path] Path to removed file or directory.
  #
  def safe_rmtree(*args)
    with_path(*args) do |path|
      invoke_backend :safe_rmtree, internal_path
      Path path
    end
  end

  # Removes file or directory. If it's a directory it will be removed
  # recursively.
  #
  # This method behaves exactly like {#rmtree} but will raise exceptions
  # e.g. when file does not exist.
  #
  # @return [Path] Path to removed file or directory.
  #
  def rmtree!(*args)
    with_path(*args) do |path|
      invoke_backend :rmtree!, internal_path
      Path path
    end
  end
  alias rm_r rmtree!

  # Removes file or directory. If it's a directory it will be removed
  # recursively.
  #
  # This method behaves exactly like {#safe_rmtree} but will raise exceptions
  # e.g. when file does not exist.
  #
  # @return [Path] Path to removed file or directory.
  #
  def safe_rmtree!(*args)
    with_path(*args) do |path|
      invoke_backend :safe_rmtree!, internal_path
      Path path
    end
  end

  private

  def escaped_glob_path
    internal_path.gsub(/[\[\]\*\?\{\}]/, '\\\\\0')
  end
end
