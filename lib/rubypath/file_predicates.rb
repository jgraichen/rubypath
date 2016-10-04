# frozen_string_literal: true
class Path
  # @!group File Predicates

  # Check if path points to file.
  #
  # @return [Boolean] True if path is a file.
  # @see ::File.file?
  #
  def file?
    invoke_backend :file?
  end

  # Check if path points to an existing location.
  #
  # @return [Boolean] True if path exists.
  # @see ::File.exists?
  #
  def exists?
    invoke_backend :exists?
  end
  alias exist? exists?
  alias existent? exists?

  # Check if path points to a directory.
  #
  # @return [Boolean] True if path is a directory.
  # @see ::File.directory?
  #
  def directory?
    invoke_backend :directory?
  end
end
