# frozen_string_literal: true

class Path
  # @!group Path Predicates

  # Check if path is an absolute path.
  #
  # An absolute path is a path with a leading slash.
  #
  # @return [Boolean] True if path is absolute.
  # @see #relative?
  #
  def absolute?
    internal_path[0] == '/'
  end

  # Check if path is a relative path.
  #
  # A relative path does not start with a slash.
  #
  # @return [Boolean] True if path is relative.
  # @see #absolute?
  #
  def relative?
    !absolute?
  end

  # @overload mountpoint?([Path, String], ...)
  #   Join current and given paths and check if resulting
  #   path points to a mountpoint.
  #
  #   @example
  #     Path('/').mountpoint?('tmp')
  #     #=> true
  #
  # @overload mountpoint?
  #   Check if current path is a mountpoint.
  #
  #   @example
  #     Path('/tmp').mountpoint?
  #     #=> true
  #
  # @return [Boolean] True if path is a mountpoint, false otherwise.
  # @see Pathname#mountpoint?
  #
  def mountpoint?(*args)
    with_path(*args) do |path|
      Backend.instance.mountpoint? path
    end
  end

  # Check if file or directory is a dot file.
  #
  # @example
  #   Path("~/.gitconfig").dotfile?
  #   #=> true
  #
  # @return [Boolean] True if file is a dot file otherwise false.
  #
  def dotfile?
    name[0] == '.'
  end
end
